# frozen_string_literal: true

require 'rails_helper'
require 'benchmark'

RSpec.describe "Api::V0::Auth Password Reset", type: :request do
  include ActiveJob::TestHelper

  let(:user) { create(:user, email: "test@example.com", password: "oldpassword123", password_confirmation: "oldpassword123") }
  let(:headers) { { "Content-Type" => "application/json" } }

  describe "POST /api/v0/auth/reset_password" do
    let(:endpoint) { "/api/v0/auth/reset_password" }

    context "with valid email of existing user" do
      let(:params) { { email: user.email } }

      it "returns success response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:success]).to be true
        expect(json_response[:data][:message]).to include("If an account exists")
      end

      it "creates a password reset token" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.to change(PasswordResetToken, :count).by(1)
      end

      it "sends an email to the user" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.to have_enqueued_mail(PasswordResetMailer, :reset_password_otp)
      end

      it "invalidates existing unused tokens" do
        existing_token = create(:password_reset_token, user: user, used_at: nil)

        post endpoint, params: params.to_json, headers: headers

        existing_token.reload
        expect(existing_token.used_at).not_to be_nil
      end

      it "stores OTP code digest (not plain text)" do
        post endpoint, params: params.to_json, headers: headers

        token = PasswordResetToken.last
        expect(token.otp_code_digest).to be_present
        expect(token.otp_code_digest).not_to match(/^\d{6}$/)
      end

      it "sets expiry time to 15 minutes from now" do
        post endpoint, params: params.to_json, headers: headers

        token = PasswordResetToken.last
        expect(token.expires_at).to be_within(2.seconds).of(15.minutes.from_now)
      end
    end

    context "with non-existent email" do
      let(:params) { { email: "nonexistent@example.com" } }

      it "returns success response (security: no user enumeration)" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:success]).to be true
        expect(json_response[:data][:message]).to include("If an account exists")
      end

      it "does not create a password reset token" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.not_to change(PasswordResetToken, :count)
      end

      it "does not send an email" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.not_to have_enqueued_mail
      end
    end

    context "with case variations in email" do
      let(:params) { { email: user.email.upcase } }

      it "finds user case-insensitively" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.to change(PasswordResetToken, :count).by(1)
      end
    end

    context "with email containing whitespace" do
      let(:params) { { email: "  #{user.email}  " } }

      it "strips whitespace and finds user" do
        expect {
          post endpoint, params: params.to_json, headers: headers
        }.to change(PasswordResetToken, :count).by(1)
      end
    end

    context "with missing email" do
      let(:params) { {} }

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:success]).to be false
        expect(json_response[:errors]).to be_present
      end
    end

    context "with empty email" do
      let(:params) { { email: "" } }

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:success]).to be false
      end
    end

    context "timing attack prevention" do
      it "takes similar time for existing and non-existing users" do
        existing_email = user.email
        non_existing_email = "nonexistent@example.com"

        time_for_existing = Benchmark.realtime do
          post endpoint, params: { email: existing_email }.to_json, headers: headers
        end

        time_for_non_existing = Benchmark.realtime do
          post endpoint, params: { email: non_existing_email }.to_json, headers: headers
        end

        # Both should take at least 100ms (our minimum sleep time)
        expect(time_for_existing).to be >= 0.1
        expect(time_for_non_existing).to be >= 0.1

        # Difference should be less than 1 second (accounting for random sleep)
        expect((time_for_existing - time_for_non_existing).abs).to be < 1
      end
    end
  end

  describe "POST /api/v0/auth/verify_reset_otp" do
    let(:endpoint) { "/api/v0/auth/verify_reset_otp" }
    let(:otp_code) { "123456" }
    let(:new_password) { "newpassword123" }

    before do
      # Create a token with known OTP
      @reset_token = user.password_reset_tokens.create!
      # Override the OTP code for testing
      @reset_token.update_columns(
        otp_code_digest: Digest::SHA256.hexdigest(otp_code),
        expires_at: 15.minutes.from_now
      )
    end

    context "with valid OTP and new password" do
      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns success response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        expect(json_response[:success]).to be true
        expect(json_response[:data][:message]).to include("successfully reset")
      end

      it "updates the user's password" do
        post endpoint, params: params.to_json, headers: headers

        user.reload
        expect(user.valid_password?(new_password)).to be true
        expect(user.valid_password?("oldpassword123")).to be false
      end

      it "marks the token as used" do
        post endpoint, params: params.to_json, headers: headers

        @reset_token.reload
        expect(@reset_token.used_at).not_to be_nil
      end

      it "invalidates all other tokens for the user" do
        other_token = create(:password_reset_token, user: user, used_at: nil)

        post endpoint, params: params.to_json, headers: headers

        other_token.reload
        expect(other_token.used_at).not_to be_nil
      end

      it "allows user to sign in with new password" do
        post endpoint, params: params.to_json, headers: headers

        signin_params = { email: user.email, password: new_password }
        post "/api/v0/auth/signin", params: signin_params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
      end
    end

    context "with case variations in email" do
      let(:params) do
        {
          email: user.email.upcase,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "finds user and resets password" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:ok)
        user.reload
        expect(user.valid_password?(new_password)).to be true
      end
    end

    context "with invalid OTP code" do
      let(:params) do
        {
          email: user.email,
          otp_code: "999999",
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns error response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:success]).to be false
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end

      it "does not update the password" do
        post endpoint, params: params.to_json, headers: headers

        user.reload
        expect(user.valid_password?("oldpassword123")).to be true
        expect(user.valid_password?(new_password)).to be false
      end
    end

    context "with expired OTP token" do
      before do
        @reset_token.update_column(:expires_at, 1.hour.ago)
      end

      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns error response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end

      it "does not update the password" do
        post endpoint, params: params.to_json, headers: headers

        user.reload
        expect(user.valid_password?("oldpassword123")).to be true
      end
    end

    context "with already used OTP token" do
      before do
        @reset_token.update_column(:used_at, 1.hour.ago)
      end

      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns error response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end

      it "does not update the password" do
        post endpoint, params: params.to_json, headers: headers

        user.reload
        expect(user.valid_password?("oldpassword123")).to be true
      end
    end

    context "with OTP belonging to different user" do
      let(:other_user) { create(:user, email: "other@example.com") }
      let(:other_user_token) do
        token = other_user.password_reset_tokens.create!
        token.update_columns(
          otp_code_digest: Digest::SHA256.hexdigest("654321"),
          expires_at: 15.minutes.from_now
        )
        token
      end

      let(:params) do
        {
          email: user.email,
          otp_code: "654321", # OTP from other_user
          password: new_password,
          password_confirmation: new_password
        }
      end

      before { other_user_token }

      it "returns error response (security check)" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end

      it "does not update the password" do
        post endpoint, params: params.to_json, headers: headers

        user.reload
        expect(user.valid_password?("oldpassword123")).to be true
      end
    end

    context "with non-existent user" do
      let(:params) do
        {
          email: "nonexistent@example.com",
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns error response" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end
    end

    context "with mismatched passwords" do
      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: "differentpassword"
        }
      end

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:success]).to be false
        expect(json_response[:errors]).to have_key(:password)
      end
    end

    context "with short password" do
      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: "123",
          password_confirmation: "123"
        }
      end

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to have_key(:password)
      end
    end

    context "with invalid OTP format" do
      let(:params) do
        {
          email: user.email,
          otp_code: "12345", # Only 5 digits
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to have_key(:otp_code)
      end
    end

    context "with non-numeric OTP" do
      let(:params) do
        {
          email: user.email,
          otp_code: "abcdef",
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "returns validation error" do
        post endpoint, params: params.to_json, headers: headers

        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors]).to have_key(:otp_code)
      end
    end

    context "with missing required fields" do
      context "missing email" do
        let(:params) do
          {
            otp_code: otp_code,
            password: new_password,
            password_confirmation: new_password
          }
        end

        it "returns validation error" do
          post endpoint, params: params.to_json, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to have_key(:email)
        end
      end

      context "missing otp_code" do
        let(:params) do
          {
            email: user.email,
            password: new_password,
            password_confirmation: new_password
          }
        end

        it "returns validation error" do
          post endpoint, params: params.to_json, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to have_key(:otp_code)
        end
      end

      context "missing password" do
        let(:params) do
          {
            email: user.email,
            otp_code: otp_code,
            password_confirmation: new_password
          }
        end

        it "returns validation error" do
          post endpoint, params: params.to_json, headers: headers

          expect(response).to have_http_status(:unprocessable_entity)
          expect(json_response[:errors]).to have_key(:password)
        end
      end
    end

    context "attempting to reuse OTP after successful reset" do
      let(:params) do
        {
          email: user.email,
          otp_code: otp_code,
          password: new_password,
          password_confirmation: new_password
        }
      end

      it "fails on second attempt" do
        # First attempt - should succeed
        post endpoint, params: params.to_json, headers: headers
        expect(response).to have_http_status(:ok)

        # Second attempt with same OTP - should fail
        post endpoint, params: params.to_json, headers: headers
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response[:errors][:error]).to include("Invalid or expired")
      end
    end
  end

  # Helper method to parse JSON response
  def json_response
    JSON.parse(response.body, symbolize_names: true)
  end
end

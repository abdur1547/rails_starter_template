# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V0::Auth::Registrations', type: :request do
  describe 'POST /api/v0/auth/sign_up' do
    let(:valid_params) do
      {
        user: {
          email: 'newuser@example.com',
          password: 'password123',
          password_confirmation: 'password123',
          name: 'New User'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new user' do
        expect {
          post '/api/v0/auth/sign_up', params: valid_params, as: :json
        }.to change(User, :count).by(1)
      end

      it 'returns a success response with user data' do
        post '/api/v0/auth/sign_up', params: valid_params, as: :json

        expect(response).to have_http_status(:created)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['message']).to eq('Signed up successfully')
        expect(json_response['data']['user']['email']).to eq('newuser@example.com')
        expect(json_response['data']['user']['name']).to eq('New User')
      end

      it 'includes JWT token in Authorization header' do
        post '/api/v0/auth/sign_up', params: valid_params, as: :json

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end

      it 'signs in the user automatically' do
        post '/api/v0/auth/sign_up', params: valid_params, as: :json
        token = extract_token_from_response(response)

        # Verify the token works by accessing protected endpoint
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with invalid email' do
      it 'returns an error response' do
        invalid_params = valid_params.deep_dup
        invalid_params[:user][:email] = 'invalid_email'

        post '/api/v0/auth/sign_up', params: invalid_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']).to eq('Registration failed')
        expect(json_response['errors']).to have_key('email')
      end
    end

    context 'with duplicate email' do
      let!(:existing_user) { create(:user, email: 'existing@example.com') }

      it 'returns an error response' do
        duplicate_params = valid_params.deep_dup
        duplicate_params[:user][:email] = 'existing@example.com'

        post '/api/v0/auth/sign_up', params: duplicate_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['errors']['email']).to include('has already been taken')
      end
    end

    context 'with password mismatch' do
      it 'returns an error response' do
        mismatch_params = valid_params.deep_dup
        mismatch_params[:user][:password_confirmation] = 'different_password'

        post '/api/v0/auth/sign_up', params: mismatch_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['errors']['password_confirmation']).to include("doesn't match Password")
      end
    end

    context 'with missing name' do
      it 'returns an error response' do
        missing_name_params = valid_params.deep_dup
        missing_name_params[:user].delete(:name)

        post '/api/v0/auth/sign_up', params: missing_name_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['errors']['name']).to include("can't be blank")
      end
    end

    context 'with short password' do
      it 'returns an error response' do
        short_password_params = valid_params.deep_dup
        short_password_params[:user][:password] = '12345'
        short_password_params[:user][:password_confirmation] = '12345'

        post '/api/v0/auth/sign_up', params: short_password_params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['errors']['password']).to include('is too short (minimum is 6 characters)')
      end
    end
  end
end

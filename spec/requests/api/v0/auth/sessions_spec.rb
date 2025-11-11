# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V0::Auth::Sessions', type: :request do
  describe 'POST /api/v0/auth/sign_in' do
    let(:user) { create(:user, password: 'password123') }

    context 'with valid credentials' do
      it 'returns a success response with user data' do
        post '/api/v0/auth/sign_in', params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }, as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['message']).to eq('Signed in successfully')
        expect(json_response['data']['user']['email']).to eq(user.email)
      end

      it 'includes JWT token in Authorization header' do
        post '/api/v0/auth/sign_in', params: {
          user: {
            email: user.email,
            password: 'password123'
          }
        }, as: :json

        expect(response.headers['Authorization']).to be_present
        expect(response.headers['Authorization']).to start_with('Bearer ')
      end
    end

    context 'with invalid email' do
      it 'returns an error response' do
        post '/api/v0/auth/sign_in', params: {
          user: {
            email: 'wrong@example.com',
            password: 'password123'
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid password' do
      it 'returns an error response' do
        post '/api/v0/auth/sign_in', params: {
          user: {
            email: user.email,
            password: 'wrongpassword'
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with missing parameters' do
      it 'returns an error when email is missing' do
        post '/api/v0/auth/sign_in', params: {
          user: {
            password: 'password123'
          }
        }, as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end
  end

  describe 'DELETE /api/v0/auth/sign_out' do
    let(:user) { create(:user, password: 'password123') }
    let(:token) { api_sign_in(user, 'password123') }

    context 'with valid token' do
      it 'signs out the user successfully' do
        delete '/api/v0/auth/sign_out', headers: auth_headers(token), as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['message']).to eq('Signed out successfully')
      end

      it 'revokes the JWT token' do
        delete '/api/v0/auth/sign_out', headers: auth_headers(token), as: :json

        # Try to use the same token again
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'without token' do
      it 'returns an error response' do
        delete '/api/v0/auth/sign_out', as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
      end
    end
  end
end

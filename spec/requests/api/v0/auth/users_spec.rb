# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V0::Auth::Users', type: :request do
  describe 'GET /api/v0/auth/user' do
    let(:user) { create(:user, :with_tracking, password: 'password123') }
    let(:token) { api_sign_in(user, 'password123') }

    context 'with valid token' do
      it 'returns current user data' do
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json

        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(true)
        expect(json_response['data']['user']['email']).to eq(user.email)
        expect(json_response['data']['user']['name']).to eq(user.name)
      end

      it 'includes detailed user information' do
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json

        json_response = JSON.parse(response.body)
        user_data = json_response['data']['user']

        # Basic fields
        expect(user_data).to have_key('id')
        expect(user_data).to have_key('email')
        expect(user_data).to have_key('name')
        expect(user_data).to have_key('avatar_url')
        expect(user_data).to have_key('provider')
        expect(user_data).to have_key('created_at')

        # Detailed view fields (tracking)
        expect(user_data).to have_key('sign_in_count')
        expect(user_data).to have_key('current_sign_in_at')
        expect(user_data).to have_key('last_sign_in_at')
        expect(user_data).to have_key('current_sign_in_ip')
        expect(user_data).to have_key('last_sign_in_ip')
        expect(user_data).to have_key('updated_at')
      end

      it 'does not include sensitive fields' do
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json

        json_response = JSON.parse(response.body)
        user_data = json_response['data']['user']

        expect(user_data).not_to have_key('encrypted_password')
        expect(user_data).not_to have_key('reset_password_token')
        expect(user_data).not_to have_key('remember_created_at')
      end
    end

    context 'without token' do
      it 'returns unauthorized error' do
        get '/api/v0/auth/user', as: :json

        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to eq(false)
      end
    end

    context 'with invalid token' do
      it 'returns unauthorized error' do
        get '/api/v0/auth/user',
            headers: auth_headers('invalid.token.here'),
            as: :json

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'with revoked token' do
      it 'returns unauthorized error after logout' do
        # Sign out to revoke the token
        delete '/api/v0/auth/sign_out', headers: auth_headers(token), as: :json
        expect(response).to have_http_status(:ok)

        # Try to access with revoked token
        get '/api/v0/auth/user', headers: auth_headers(token), as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end

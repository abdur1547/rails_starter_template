# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/api/v0/auth', type: :request do
  describe '/signup' do
    let(:email) { Faker::Internet.email }
    let(:name) { Faker::Name }
    let(:password) { Faker::Internet.password }
    let(:params) do
      {
        email:,
        name:,
        password:
      }
    end

    before { post '/api/v0/auth/signup', params: }

    describe 'success' do
      context 'when required params are provides' do
        it 'should create user' do
          expect(response).to be_created
          expect(response).to match_json_schema('v0/user')
        end
      end
    end

    describe 'failour' do
      context 'when email is not provided' do
        let(:email) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when name is not provided' do
        let(:name) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when password is not provided' do
        let(:password) { '' }

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end

      context 'when user with email already exist' do
        let!(:user) { create(:user) }
        let(:params) do
          {
            email: user.email,
            name:,
            password:
          }
        end

        it 'should un processable response' do
          expect(response).to be_unprocessable
        end
      end
    end
  end

  describe '/signin' do
    let!(:user) { create(:user) }
    let(:email) { user.email }
    let(:password) { user.password }
    let(:params) do
      {
        email:,
        password:
      }
    end

    before { post '/api/v0/auth/signin', params: }

    describe 'success' do
      context 'when user credential are correct' do
        it 'returns ok response' do
          expect(response).to be_ok
        end
      end
    end
  end

  describe '/refresh' do
    let(:user) { create(:user) }
    let(:token_pair) { Jwt::Issuer.call(user) }
    let(:access_token) { valid_jwt(user) }
    let(:refresh_token) { token_pair[:refresh_token].token }
    let(:headers) do
      {
        Authorization: access_token
      }
    end
    let(:params) do
      {
        access_token:,
        refresh_token:
      }
    end

    before { post '/api/v0/auth/refresh', headers:, params: }

    describe 'success' do
      context 'when access_token & refresh_token are valid' do
        it 'returns new access_token' do
          expect(response).to be_created
        end
      end
    end
  end

  describe 'google_oauth2' do
    #   { 'iss' => 'https://accounts.google.com',
    #     'azp' => '114388269919-bo8c4r47so77fqp4all8k0bbbk756ihj.apps.googleusercontent.com',
    #     'aud' => '114388269919-bo8c4r47so77fqp4all8k0bbbk756ihj.apps.googleusercontent.com',
    #     'sub' => '110285926963282224306',
    #     'email' => 'khalil.ahmad1547@gmail.com',
    #     'email_verified' => 'true',
    #     'nbf' => '1727952702',
    #     'name' => 'Abdur Rahman',
    #     'picture' =>
    # 'https://lh3.googleusercontent.com/a/ACg8ocL2nkJrjbqLfk-jRu6fgo-B_y-UnnKXQldwWPC3nxjJ-9j1N0A=s96-c',
    #     'given_name' => 'Abdur',
    #     'family_name' => 'Rahman',
    #     'iat' => '1727953002',
    #     'exp' => '1727956602',
    #     'jti' => '4f6d7cdca6b6bcc320eb4b369410dea3a844ebd5',
    #     'alg' => 'RS256',
    #     'kid' => '28a421cafbe3dd889271df900f4bbf16db5c24d4',
    #     'typ' => 'JWT' }
  end
end

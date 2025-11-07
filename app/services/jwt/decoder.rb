# frozen_string_literal: true

module Jwt
  class Decoder
    attr_reader :access_token, :refresh_token, :verify

    def self.call(access_token:, verify: true)
      new(access_token, verify).call
    end

    def initialize(access_token, verify)
      @access_token = access_token
      @verify = verify
    end

    def call
      decoded_token = JWT.decode(access_token, ENV.fetch("SECRET_KEY_BASE", nil), verify, verify_iat: true)[0]
      decoded_token.symbolize_keys
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      nil
    end
  end
end

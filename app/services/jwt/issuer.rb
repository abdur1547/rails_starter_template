# frozen_string_literal: true

module Jwt
  class Issuer
    attr_reader :user

    def self.call(user)
      new(user).call
    end

    def initialize(user)
      @user = user
    end

    def call
      access_token = Jwt::Encoder.call(user).first
      refresh_token = user.refresh_tokens.create!
      { access_token:, refresh_token: }
    end
  end
end

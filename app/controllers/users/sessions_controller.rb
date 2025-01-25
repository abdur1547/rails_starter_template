# rubocop:disable Rails/LexicallyScopedActionFilter
# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [ :create ]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  protected

  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: Users::Helpers::USER_PERMITTED_PARAMS)
  end

  def after_sign_out_path_for(_resource_or_scope)
    new_user_session_path
  end

  def after_sign_in_path_for(resource_or_scope)
    stored_location_for(resource_or_scope) || root_path
  end
end

# rubocop:enable Rails/LexicallyScopedActionFilter

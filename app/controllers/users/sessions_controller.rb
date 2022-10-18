class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  prepend_before_action :require_no_authentication, only: :create
  prepend_before_action :allow_params_authentication!, only: :create
  prepend_before_action(only: [:create]) { request.env["devise.skip_timeout"] = true }

  # GET /resource/sign_in
  def new
    super && return if current_user.blank?
    set_flash_message!(:notice, :already_authenticated)
    redirect_to root_path
  end

  # POST /resource/sign_in
  def create
    super
  end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:username])
  end
end

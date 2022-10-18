class ApplicationController < ActionController::Base
  include Pundit
  include Pagy::Backend

  protect_from_forgery with: :exception, if: :verify_api

  # PaperTrail provides a callback that will assign current_user.id to whodunnit.
  before_action :set_paper_trail_whodunnit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  def after_sign_out_path_for(resource_or_scope)
    new_session_path(resource_or_scope)
  end

  private

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_to(request.referer || root_path)
  end

  def verify_api
    params[:controller].split('/')[0] != 'devise_token_auth'
  end
end

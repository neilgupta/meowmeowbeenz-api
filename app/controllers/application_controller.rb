class ApplicationController < ActionController::Base
  before_filter :require_token, :except => [:index]

  def require_token
    raise Exceptionally::Unauthorized.new("Invalid token") unless current_user
  end

  def current_user
    @current_user ||= User.find_by_token(params[:token])
  end
end

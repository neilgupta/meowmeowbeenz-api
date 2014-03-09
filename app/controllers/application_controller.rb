class ApplicationController < ActionController::Base
  class UnauthorizedError < StandardError; end
  class NotFoundError < StandardError; end

  rescue_from Exception, :with => :generic500Exception
  rescue_from ArgumentError, :with => :generic500Exception
  rescue_from UnauthorizedError, :with => :unauthorizedEx
  rescue_from NotFoundError, :with => :missingRecord
  rescue_from Apipie::ParamMissing, :with => :missingParam
  rescue_from Apipie::ParamInvalid, :with => :missingParam
  rescue_from ActiveRecord::RecordNotFound, :with => :missingRecord
  rescue_from ActiveRecord::RecordInvalid, :with => :recordInvalidHandler

  before_filter :require_token

  def require_token
    raise UnauthorizedError.new("Invalid token") unless current_user
  end

  def current_user
    @current_user ||= User.find_by_token(params[:token])
  end

  # Raise 400 error
  def missingParam(error)
    raiseError(error.message, 400)
  end

  # Raise 403 error
  def unauthorizedEx(error)
    raiseError(error.message, 403)
  end

  # Raise 404 error
  def missingRecord(error)
    raiseError(error.message, 404)
  end

  # Raise 409 error
  def recordInvalidHandler(error)
    raiseError(error.message, 409)
  end

  # Raise 500 error
  def generic500Exception(error)
    raiseError(error.message, 500)
  end

  # Output JSON-formatted error response
  def raiseError(error, status)
    render :json => { :errors => error }, :status => status
  end
end

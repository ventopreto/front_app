class HomeController < ApplicationController
  rescue_from JWT::DecodeError, with: :unauthorized
  rescue_from JWT::VerificationError, with: :unauthorized
  rescue_from JWT::ExpiredSignature, with: :unauthorized

  def index
    @token = session["jwt_token"] if token_valid?
  end

  private

  def token_valid?
    token_not_expired?
  end

  def token
    @token = session["jwt_token"]&.split&.last
  end

  def token_not_expired?
    payload = Warden::JWTAuth::TokenDecoder.new.call(token)
    expiration_time = Time.zone.at(payload["exp"])
    expiration_time > Time.zone.now
  end

  def unauthorized
    Rails.logger.error("Token validation error")
    session.destroy
    redirect_to new_user_session_path
  end
end

# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  def create
    super do |user|
      @token = generate_jwt_token_for_user(user)
    end
  end

  private

  def generate_jwt_token_for_user(user)
    token = Warden::JWTAuth::UserEncoder.new.call(user, :user, nil).first
    session[:jwt_token] = "Bearer #{token}"
  end
end

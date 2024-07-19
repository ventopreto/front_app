# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  def create
    super do |resource|
      @token = request.env["warden-jwt_auth.token"]
      session[:jwt_token] = "Bearer #{@token}"
    end
  end
end

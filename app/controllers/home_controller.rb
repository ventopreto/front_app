class HomeController < ApplicationController
  def index
    @token = session["jwt_token"]
  end
end

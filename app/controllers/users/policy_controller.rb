class Users::PolicyController < ApplicationController
  before_action :token_valid?
  rescue_from JWT::DecodeError, with: :unauthorized
  rescue_from JWT::VerificationError, with: :unauthorized
  rescue_from JWT::ExpiredSignature, with: :unauthorized

  def index
    response = Faraday.get("http://rest_app:3001/api/v1/policy", nil, request_headers)
    @policies = index_response(response)
  end

  def new
  end

  def create
    conn = Faraday.new(url: "http://graphql_app:3002", headers: request_headers)
    response = conn.post("/graphql") do |req|
      req.params["limit"] = 100
      req.body = {query: query}.to_json
    end

    if response.status == 200
      flash[:success] = create_response(response)
      redirect_to users_policy_index_path
    else
      flash[:warning] = "Policy not created"
      render :new
    end
  end

  private

  def payment_data
    order_id = SecureRandom.uuid
    conn = Faraday.new(url: "https://api.stripe.com/v1/payment_links", headers: payment_link_headers)
    response = conn.post("/v1/payment_links") do |req|
      req.body = {
        "line_items[0][price]": ENV["STRIPE_PRICE_KEY"],
        "line_items[0][quantity]": "1",
        "metadata[order_id]": "#{order_id}"

      }.to_query
    end
    JSON.parse(response.body)
  end

  def payment_link_headers
    {
      Authorization: "Basic #{Base64.strict_encode64(ENV["STRIPE_SECRET_KEY"])}",
      content_type: "application/x-www-form-urlencoded"
    }
  end

  def policy_params
    params.permit(:name, :cpf, :registration_plate, :model, :year, :brand, :start_date_coverage, :end_date_coverage, :payment_link, :payment_status)
  end

  def request_headers
    {
      Authorization: "Bearer #{@token}",
      content_type: "application/json"
    }
  end

  def query
    payment_params = payment_data
    <<-GRAPHQL
  mutation {
    policyCreate(input: {policyInput: {
      start_date_coverage: "#{params[:start_date_coverage]}"
      end_date_coverage: "#{params[:end_date_coverage]}"
      payment_link: "#{payment_params["url"]}"
      payment_id: "#{payment_params["metadata"]["order_id"]}"
      vehicle: {
        brand: "#{params[:brand]}"
        model: "#{params[:model]}"
        year: "#{params[:year]}"
        registration_plate: "#{params[:registration_plate]}"
      }
      insured: {
        name: "#{params[:name]}"
        cpf: "#{params[:cpf]}"
      }
    }}) {
      message
    }
  }
    GRAPHQL
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

  def index_response(response)
    JSON.parse(response.body)
  end

  def create_response(response)
    JSON.parse(response.body)["data"]["policyCreate"]["message"]
  end
end

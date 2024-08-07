# frozen_string_literal: true

class Users::PaymentsController < ApplicationController
  def new
  end

  def create
    expires_at = Time.now.to_i + 24 * 60 * 60
    @session = Stripe::Checkout::Session.create({
      payment_method_types: ["card"],
      line_items: [{
        price: "price_1PguO0RwD92VFeo0MjjWy9RQ",
        quantity: 1
      }],
      mode: "payment",
      expires_at: expires_at
    })

    redirect_to @session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    flash[:error] = e.message
    redirect_to new_users_payment_path
  end
end

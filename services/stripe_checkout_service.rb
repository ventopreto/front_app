class StripeCheckoutService
  def create
    expires_at = Time.now.to_i + 24 * 60 * 60
    @session = Stripe::Checkout::Session.create({
      payment_method_types: ["card"],
      line_items: [{
        price: ENV["STRIPE_PRICE_KEY"],
        quantity: 1
      }],
      mode: "payment",
      expires_at: expires_at
    })
  end
end

class PaymentsController < ApplicationController
  before_action :set_order

  def new
    # @intent = Stripe::PaymentIntent.create({
    #     amount: @order.amount_cents,
    #     currency: @order.amount.currency,
    #     payment_method_types: ['card'],
    #     setup_future_usage: 'off_session',
    # })
    # @order.update(intent_id: @intent.id)

    customer = Stripe::Customer.create(
      email:  current_user.email,
      name: current_user.email,
    )

    stripe_session = Stripe::Checkout::Session.create(
      customer: customer.id,
      payment_method_types: ['card'],
      locale: 'auto',
      line_items: [{
        name: @order.product_sku,
        # images: [@order.product.photo_url],
        description: "Payment for teddy #{@order.product_sku} for order #{@order.id}",
        amount: @order.amount_cents,
        currency: @order.amount.currency,
        quantity: 1,
      }],
      # subscription_data: {
      #   items: [{
      #     plan: 'plan_123',
      #   }],
      #   trial_period_days: 30,
      # },
      success_url: order_url(@order),
      cancel_url: new_order_payment_url(@order),
    )
    @stripe_publishable_key = Rails.configuration.stripe[:publishable_key]
    @session_id = stripe_session.id
  end
private

  def set_order
    @order = current_user.orders.where(state: 'pending').find(params[:order_id])
  end
end

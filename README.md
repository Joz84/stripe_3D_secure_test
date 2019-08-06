# How to install new Stripe 3D Secure with Checkout

## Step 1 - Update Stripe Account with new API & activate checkout
Activate checkout in https://dashboard.stripe.com/account/checkout/settings

## Step 2 - Install gem stripe

## Step 3 - Install Initializer & Keys
```ruby
# config/initializers/stripe.rb
Rails.configuration.stripe = {
  publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
  secret_key:      ENV['STRIPE_SECRET_KEY']
}

Stripe.api_key = Rails.configuration.stripe[:secret_key]
```

```ruby
# .env
STRIPE_PUBLISHABLE_KEY=pk_**H
STRIPE_SECRET_KEY=sk_**f
```

## Step 4 - In Payment Controller
```ruby
class PaymentsController < ApplicationController
  before_action :set_order

  def new
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
        description: "Payment for teddy #{@order.product_sku} for order #{@order.id}",
        amount: @order.amount_cents,
        currency: @order.amount.currency,
        quantity: 1,
      }],
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

```

## Step 5 - Payment Form
```html
<h1>Purchase of product <%= @order.product_sku %></h1>
  <article>
    <label class="amount">
      <span>Amount: <%= humanized_money_with_symbol(@order.amount) %></span>
    </label>
  </article>
  <button id="checkout-button"
          data-sessionid="<%= @session_id %>"
          data-stripekey="<%= @stripe_publishable_key %>">
    Pay
  </button>
```


## Step 6 - Stripe JS
```javascript
var checkoutButton = document.querySelector('#checkout-button');
if (checkoutButton) {
  checkoutButton.addEventListener('click', function (event) {
    var stripe = Stripe(event.currentTarget.dataset.stripekey);
    stripe.redirectToCheckout({
      sessionId: event.currentTarget.dataset.sessionid
    }).then(function (result) {
      // If `redirectToCheckout` fails due to a browser or network
      // error, display the localized error message to your customer
      // using `result.error.message`.
      result.error.message
    });
  });
}
```

## Step 7 - Order Controller
```ruby
class OrdersController < ApplicationController

  def create
    product = Product.find(params[:product_id])
    order  = Order.create!(product_sku: product.sku, amount: product.price, state: 'pending', user: current_user)
    redirect_to new_order_payment_path(order)
  end
  def show
    @order = current_user.orders.find(params[:id])
    @order.update(payment: 'done', state: 'paid')
    flash[:notice] = "Paiement validé avec succés"
  end
end
```

## Additional infos - in case
```
Custom de la page de demande de détails de la carte - Ajout Logo & Couleur
https://dashboard.stripe.com/account/branding

Envoi automatique d'un email au paiement d'un utilisateur - Reçu
https://stripe.com/docs/receipts#receipts-checkout

Activer l'email pour les cartes arrivant à expiration & en cas d'erreur de paiement
https://dashboard.stripe.com/account/billing/automatic

```

Docs Stripe associated
```
https://stripe.com/docs/api/checkout/sessions/object
https://stripe.com/docs/payments/checkout/server
https://stripe.com/docs/stripe-js/elements/quickstart
https://stripe.com/docs/testing#cards
```

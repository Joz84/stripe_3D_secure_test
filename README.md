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

Ajouter dans layout/application.html.erb
```html
<script src="https://js.stripe.com/v3/"></script>
```
## Step 4 - migrations
```shell
rails g migration AddStripeSessionIdToOrders stripe_session_id 
rails g migration AddStripeIdToUsers stripe_id
```

## Step 5 - routes
```ruby
Rails.application.routes.draw do
  get "order/paid/:id", to: "orders#paid", as: "paid_order"
  devise_for :users
  root to: 'teddies#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  resources :teddies, only: [:index, :show]
  resources :orders, only: [:show, :create] do
    resources :payments, only: [:new]
  end
end
```

## Step 6 - In Payment Controller
```ruby
class PaymentsController < ApplicationController
  before_action :set_order

  def new
    if current_user.stripe_id.nil?
      customer = Stripe::Customer.create(
        email:  current_user.email,
        name: current_user.email,
      )
      current_user.update(stripe_id: customer.id)
    end

    stripe_session = Stripe::Checkout::Session.create(
      customer: current_user.stripe_id,
      payment_method_types: ['card'],
      locale: 'auto',
      line_items: [{
        name: @order.teddy_sku,
        description: "Payment for teddy #{@order.teddy_sku} for order #{@order.id}",
        amount: @order.amount_cents,
        currency: @order.amount.currency,
        quantity: 1,
      }],
      success_url: paid_order_url(@order),
      cancel_url: new_order_payment_url(@order),
    )
    @stripe_publishable_key = Rails.configuration.stripe[:publishable_key]
    @order.update(stripe_session_id: stripe_session.id)
  end

private

  def set_order
    @order = current_user.orders.where(state: 'pending').find(params[:order_id])
  end

end

```

## Step 7 - Payment Form
```html
<div class="container text-center">
  <h1>Purchase of product <%= @order.teddy_sku %></h1>
    <article>
      <label class="amount">
        <span>Amount: <%= humanized_money_with_symbol(@order.amount) %></span>
      </label>
    </article>
    <button id="checkout-button"
            class="btn btn-primary"
            data-sessionid="<%= @order.stripe_session_id %>"
            data-stripekey="<%= @stripe_publishable_key %>">
      Pay
    </button>
</div>
```


## Step 8 - Stripe JS
```javascript
function flash(innerHTML) {
  const flash = document.getElementById('flash');
  flash.innerHTML = innerHTML;
};

var checkoutButton = document.querySelector('#checkout-button');
if (checkoutButton) {
  checkoutButton.addEventListener('click', function (event) {
    var stripe = Stripe(event.currentTarget.dataset.stripekey);
    stripe.redirectToCheckout({
      sessionId: event.currentTarget.dataset.sessionid
    }).then(function (result) {
      flash('<%= j render "shared/flashes", alert: "Une erreur s est produite lors du paiement : " + result.error.message %>');
    });
  });
}
```

## Step 9 - Order Controller
```ruby
class OrdersController < ApplicationController
  def paid
    @order = current_user.orders.find(params[:id])
    @order.update(state: 'paid')
    redirect_to @order
  end

  def show
    @order = current_user.orders.find(params[:id])
    flash[:notice] = "Paiement validé avec succès"
  end

  def create
  teddy = Teddy.find(params[:teddy_id])
  order  = Order.create!(teddy_sku: teddy.sku, amount: teddy.price, state: 'pending', user: current_user)
  redirect_to new_order_payment_path(order)
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

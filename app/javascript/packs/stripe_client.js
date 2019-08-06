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

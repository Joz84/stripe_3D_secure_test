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
      if (result.error.message) {
        // var displayError = document.getElementById('error-message');
        // displayError.textContent = result.error.message;
        flash('<%= j render "shared/flashes", alert: "Une erreur s est produite lors du paiement : " + result.error.message %>');
      }
    });
  });
}

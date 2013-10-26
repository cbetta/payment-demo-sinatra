require "sinatra"
require "paypal-sdk-rest"

include PayPal::SDK::REST

enable :sessions

get "/" do
  payment = Payment.new({
    intent: "sale",
    payer: {
      payment_method: "paypal"
    },
    redirect_urls: {
      return_url: "http://127.0.0.1:4567/callback",
      cancel_url: "http://127.0.0.1:4567/cancel"
    },
    transactions: [
      {
        amount: {
            total: "1000.00",
            currency: "EUR"
          },
        description: "Battle Axe"
      }
    ]
  })

  if payment.create
    session[:payment_id] = payment.id
    redirect payment.links.find {|link| link.method == "REDIRECT" }.href
  else
    "Oops, Cristiano made a mistake"
  end
end

get "/cancel" do
  "You've cancelled, the axe is not yours"
end

get "/callback" do
  payment = Payment.find(session[:payment_id])

  if payment.execute(payer_id: params["PayerID"])
    "The axe is yours"
  else
    "Sorry, Cristiano made another mistake"
  end
end









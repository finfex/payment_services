# Copyright (c) 2018 FINFEX <danil@brandymint.ru>

module PaymentServices
  class RBK < Base
    CHECKOUT_URL = 'https://checkout.rbk.money/v1/checkout.html'
    autoload :Invoicer, 'payment_services/rbk/invoicer'
    register :invoicer, Invoicer
  end
end

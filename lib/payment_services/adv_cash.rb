module PaymentServices
  class AdvCash < Base
    autoload :Invoicer, 'payment_services/adv_cash/invoicer'

    register :invoicer, Invoicer
  end
end

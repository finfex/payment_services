module PaymentServices
  class Payeer < Base
    autoload :Invoicer, 'payment_services/payeer/invoicer'

    register :invoicer, Invoicer
  end
end

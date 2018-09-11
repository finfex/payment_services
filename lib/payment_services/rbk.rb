module PaymentServices
  class RBK < Base
    autoload :Invoicer, 'payment_services/rbk/invoicer'

    register :invoicer, Invoicer
  end
end

module PaymentServices
  class PerfectMoney < Base
    autoload :Invoicer, 'payment_services/perfect_money/invoicer'

    register :invoicer, Invoicer
  end
end

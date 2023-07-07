# frozen_string_literal: true

module PaymentServices
  class AnyPay < Base
    autoload :Invoicer, 'payment_services/any_pay/invoicer'
    register :invoicer, Invoicer
  end
end

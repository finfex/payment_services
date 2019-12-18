# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

module PaymentServices
  class AnyMoney < Base
    autoload :Invoicer, 'payment_services/any_money/invoicer'
    register :invoicer, Invoicer
  end
end

# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

module PaymentServices
  class PerfectMoney < Base
    autoload :Invoicer, 'payment_services/perfect_money/invoicer'

    register :invoicer, Invoicer
  end
end

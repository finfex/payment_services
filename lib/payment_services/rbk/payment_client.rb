# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'client'

class PaymentServices::RBK
  class PaymentClient < PaymentServices::RBK::Client
    STATES = %w[pending processed captured cancelled refunded failed].freeze
    SUCCESS_STATES = %w[processed captured].freeze
    FAIL_STATES = %w[cancelled failed].freeze
    REFUND_STATES = %w[refunded].freeze
    PENDING_STATES = %w[pending].freeze

    def refund(payment)
      safely_parse http_request(
        url: "#{API_V1}/processing/invoices/#{payment.rbk_invoice_id}/payments/#{payment.rbk_id}/refunds",
        method: :POST,
        headers: { Authorization: "Bearer #{payment.invoice.access_token}" }
      )
    end
  end
end

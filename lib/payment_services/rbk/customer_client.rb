# frozen_string_literal: true

# Copyright (c) 2018 FINFEX https://github.com/finfex

require_relative 'client'

class PaymentServices::RBK
  class CustomerClient < PaymentServices::RBK::Client
    URL = "#{API_V1}/processing/customers"

    def create_customer(user)
      request_body = {
        shopID: SHOP,
        contactInfo: {
          email: user.email,
          phone: user.phone
        },
        metadata: { user_id: user.id }
      }
      safely_parse http_request(
        url: CUSTOMERS_URL,
        method: :POST,
        body: request_body
      )
    end

    def customer_status(customer)
      safely_parse http_request(
        url: "#{CUSTOMERS_URL}/#{customer.rbk_id}",
        method: :GET
      )
    end

    def customer_events(customer)
      safely_parse http_request(
        url: "#{CUSTOMERS_URL}/#{customer.rbk_id}/events?limit=100",
        method: :GET
      )
    end

    def customer_bindings(customer)
      safely_parse http_request(
        url: "#{CUSTOMERS_URL}/#{customer.rbk_id}/bindings",
        method: :GET
      )
    end

    def get_token(customer)
      safely_parse http_request(
        url: "#{CUSTOMERS_URL}/#{customer.rbk_id}/access-tokens",
        method: :POST
      )
    end
  end
end

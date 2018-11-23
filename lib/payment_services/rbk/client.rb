class PaymentServices::RBK
  class Client
    include AutoLogger
    TIMEOUT = 1
    API_V1 = 'https://api.rbk.money/v1'
    INVOICES_URL = "#{API_V1}/processing/invoices".freeze
    CUSTOMERS_URL = "#{API_V1}/processing/customers".freeze
    MAX_LIVE = 18.minutes
    SHOP = 'TEST'
    DEFAULT_CURRENCY = 'RUB'
    PAYMENT_STATES = %w(pending processed captured cancelled refunded failed)
    PAYMENT_SUCCESS_STATES = %w(processed captured)
    PAYMENT_FAIL_STATES = %w(cancelled refunded failed)
    PAYMENT_PENDING_STATES = %w(pending)

    def create_invoice(order_id: , amount: )
      request_body = {
        shopID: SHOP,
        dueDate: Time.zone.now + MAX_LIVE,
        amount: amount,
        currency: DEFAULT_CURRENCY,
        product: I18n.t('payment_systems.default_product', order_id: order_id),
        metadata: { order_public_id: order_id }
      }
      safely_parse http_request(
        url: INVOICES_URL,
        method: :POST,
        body: request_body
      )
    end

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

    def pay_invoice_by_customer(invoice: , customer: )
      request_body = {
        flow: { type: 'PaymentFlowInstant' },
        payer: {
          payerType: 'CustomerPayer',
          customerID: customer.rbk_id
        }
      }
      safely_parse http_request(
        url: "#{INVOICES_URL}/#{invoice.rbk_invoice_id}/payments",
        method: :POST,
        body: request_body,
        headers: { Authorization: "Bearer #{invoice.access_payment_token}" }
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

    private

    def http_request(url: , method: , body: nil, headers: {})
      uri = URI.parse(url)
      https = http(uri)
      request = build_request(uri: uri, method: method, body: body, headers: headers)
      logger.info "Request type: #{method} to #{uri} with payload #{request.body}"
      https.request(request)
    end

    def build_request(uri: , method: , body: nil, headers: {})
      request = if method == :POST
                  Net::HTTP::Post.new(uri.request_uri, build_headers(headers))
                elsif method == :GET
                  Net::HTTP::Get.new(uri.request_uri, build_headers(headers))
                else
                  raise "Запрос #{method} не поддерживается!"
                end
      request.body = body.to_json if body
      request
    end

    def http(uri)
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: true,
                      verify_mode: OpenSSL::SSL::VERIFY_NONE,
                      open_timeout: TIMEOUT,
                      read_timeout: TIMEOUT
                     )
    end

    def build_headers(headers)
      {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-cache',
        'X-Request-ID': SecureRandom.hex,
        'Authorization': "Bearer #{Secrets.rbk_money_api_key}"
      }.merge(headers)
    end

    def safely_parse(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => err
      logger.warn "Request failed #{response.class} #{response.body}"
      Bugsnag.notify err do |report|
        report.add_tab(:rbk_data, {
          response_class: response.class,
          response_body: response.body
        })
      end
      response.body
    end
  end
end

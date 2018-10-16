class PaymentServices::RBK
  class Client
    include AutoLogger
    TIMEOUT = 1
    API_V1 = 'https://api.rbk.money/v1'
    CREATE_INVOICE_URL = "#{API_V1}/processing/invoices".freeze
    CREATE_CUSTOMER_URL = "#{API_V1}/processing/customers".freeze
    MAX_LIVE = 18.minutes
    SHOP = 'TEST'
    DEFAULT_CURRENCY = 'RUB'

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
        url: CREATE_INVOICE_URL,
        method: :post,
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
        url: CREATE_CUSTOMER_URL,
        method: :post,
        body: request_body
      )
    end

    def create_payment
      #   curl -X POST \
      #   https://api.rbk.money/v1/processing/invoices/xtdikju7jk/payments \
      #   -H 'Authorization: Bearer {INVOICE_ACCESS_TOKEN}' \
      #   -H 'Cache-Control: no-cache' \
      #   -H 'Content-Type: application/json; charset=utf-8' \
      #   -H 'X-Request-ID: 1518694583' \
      #   -d '{
      #   "flow": {
      #     "type": "PaymentFlowInstant"
      #   },
      #   "payer": {
      #     "payerType": "CustomerPayer",
      #     "customerID": "xtdX5zlluy"
      #   }
      # }'
    end

    def check_customer_status
      # curl -X GET \
      #   https://api.rbk.money/v2/processing/customers/10UWY0qQpU0 \
      #   -H 'Authorization: Bearer {API_KEY}' \
      #   -H 'Cache-Control: no-cache' \
      #   -H 'Content-Type: application/json; charset=utf-8' \
      #   -H 'X-Request-ID: 1527070201'
      # в случае успешной привязки объект плательщика переходит в состояние ready

      # response
      # {
      #     "contactInfo": {
      #         "email": "user@example.com",
      #         "phoneNumber": "79876543210"
      #     },
      #     "id": "10UWY0qQpU0",
      #     "metadata": {},
      #     "shopID": "TEST",
      #     "status": "ready"
      # }
      # update rbk customer status
    end

    private

    def http_request(url: , method: , body: )
      uri = URI.parse(url)
      https = http(uri)
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = body.to_json

      logger.info "Request type: #{method} to #{uri} with payload #{request.body}"
      https.request(request)
    end

    def http(uri)
      Net::HTTP.start(uri.host, uri.port,
                      use_ssl: true,
                      verify_mode: OpenSSL::SSL::VERIFY_NONE,
                      open_timeout: TIMEOUT,
                      read_timeout: TIMEOUT
                     )
    end

    def headers
      {
        'Content-Type': 'application/json; charset=utf-8',
        'Cache-Control': 'no-cache',
        'X-Request-ID': SecureRandom.hex,
        'Authorization': "Bearer #{Secrets.rbk_money_api_key}"
      }
    end

    def safely_parse(response)
      JSON.parse(response.body)
    rescue JSON::ParserError => err
      logger.warn "Request failed #{response.class} #{response.body}"
      Bugsnag.notify error do |report|
        report.add_tab(:rbk_data, {
          response_class: response.class,
          response_body: response.body
        })
      end
      response.body
    end
  end
end

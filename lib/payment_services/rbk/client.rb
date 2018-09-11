module RBK
  class Client
    include AutoLogger
    TIMEOUT = 1
    CREATE_URL = 'https://api.rbk.money/v1/processing/invoices'.freeze
    MAX_LIVE = PreliminaryOrder::MAX_LIVE - 2.minutes
    SHOP = 'TEST'
    DEFAULT_CURRENCY = 'RUB'

    def create_invoice(invoice)
      response = rbk_api_call(invoice)
      parsed_response = JSON.parse(response.body)
      { id: parsed_response['invoice']['id'], payload: parsed_response }
    rescue JSON::ParserError => err
      logger.warn "Request failed #{response.class} #{response.body}"
      Bugsnag.notify err do |report|
        report.add_tab(:rbk_data, {
          request_body: build_body(invoice),
          response_class: response.class,
          response_body: response.body
        })
      end
      { payload: { raw: response.body } }
    end

    private

    def rbk_api_call(invoice)
      uri = URI.parse(CREATE_URL)
      https = http(uri)
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = build_body(invoice)

      logger.info "Post to #{uri} with payload #{request.body}"
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
        'X-Request-ID': SecureRandom.hex,
        'Authorization': "Bearer #{Secrets.rbk_money_api_key}"
      }
    end

    def build_body(invoice)
      {
        shopID: SHOP,
        dueDate: invoice.order.created_at + MAX_LIVE,
        amount: invoice.amount_in_cents,
        currency: DEFAULT_CURRENCY,
        product: I18n.t('payment_systems.default_product', order_id: invoice.order_public_id),
        metadata: { order_public_id: invoice.order_public_id }
      }.to_json
    end
  end
end

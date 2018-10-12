class PaymentServices::RBK
  class Client
    include AutoLogger
    TIMEOUT = 1
    CREATE_URL = 'https://api.rbk.money/v1/processing/invoices'.freeze
    MAX_LIVE = 18.minutes
    SHOP = 'TEST'
    DEFAULT_CURRENCY = 'RUB'

    def create_invoice(order_id: , amount: )
      response = rbk_api_call(order_id: order_id, amount: amount)
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

    def rbk_api_call(order_id: , amount: )
      uri = URI.parse(CREATE_URL)
      https = http(uri)
      request = Net::HTTP::Post.new(uri.request_uri, headers)
      request.body = build_body(
        order_id: order_id,
        due_date: Time.zone.now + MAX_LIVE,
        amount: amount
      )

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

    def build_body(due_date: , order_id: , amount: )
      {
        shopID: SHOP,
        dueDate: due_date,
        amount: amount,
        currency: DEFAULT_CURRENCY,
        product: I18n.t('payment_systems.default_product', order_id: order_id),
        metadata: { order_public_id: order_id }
      }.to_json
    end
  end
end

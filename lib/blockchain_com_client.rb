class BlockchainComClient
  Blockchain::TIMEOUT_SECONDS = 5
  include AutoLogger
  # NOTE апи blockchain.com следит только за 20ю неиспользованными адресами. При простом режиме работе, если запросить 21й адрес
  # то апи выдаст ошибку. Параметр gap_limit частично убирает это ограничение, апи будет генерировать адреса без ошибок до значения gap_limit,
  # но следить по прежнему только за 20ю. Т.е. если поставтиь gap_limit=100, будет сгенерировано 100 адресов, но сервис будет оповещать
  # наш сервер только о приходе денег на первые 20.
  WATCH_GAP_LIMIT = 20
  DEFAULT_GAP_LIMIT = 1000

  def generate_address(callback_token)
    logger.info "blockchain.com start address generation"
    api_root = Rails.application.routes.url_helpers.public_public_api_root_url
    response = client.receive(
      Secrets.blockchain_xpub,
      CGI.escape("#{api_root}/v1/bitcoin/receive_payment?token=#{callback_token}"),
      Secrets.blockchain_key,
      DEFAULT_GAP_LIMIT
    )
    logger.info "blockchain.com generate_address succeed. Response: #{response.to_json}"
    response.address
  end

  def empty_address_in_use
    client.check_gap(Secrets.blockchain_com_xpub, Secrets.blockchain_com_key).try(:[], 'gap')
  end

  def address_to_reach_api_limit
    WATCH_GAP_LIMIT - empty_address_in_use
  end

  # NOTE пока не работает
  def get_address_balance(address)
    addr = wallet.get_address(address)
    addr.balance
  end

  private

  def wallet
    @wallet ||= Blockchain::Wallet.new(Secret.blockchain_wallet_id, Secret.blockchain_password)
  end

  def client
    Blockchain::V2::Receive.new
  end
end

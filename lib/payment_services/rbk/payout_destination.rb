# frozen_string_literal: true

# Copyright (c) 2019 FINFEX https://github.com/finfex

class PaymentServices::RBK
  class PayoutDestination < ApplicationRecord
    self.table_name = 'rbk_payment_cards'

    def self.create_from_card_details(number:, name:, exp_date:, identity:)
      # запрос в токинайзер для получения токена по карте
      # запрос на создание напрвления выплаты (карты) для личность (identity)
      raise NotImplementedError
    end
  end
end

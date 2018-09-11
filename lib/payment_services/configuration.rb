module PaymentServices
  class Configuration
    attr_accessor :registry
    attr_accessor :preliminary_order_class # PreliminaryOrder

    def initialize
      @registry = []
      @preliminary_order_class = nil
    end
  end
end

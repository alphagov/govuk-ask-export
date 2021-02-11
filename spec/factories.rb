class HashStrategy
  def initialize
    @strategy = FactoryBot.strategy_by_name(:create).new
  end

  delegate :association, to: :@strategy

  def result(evaluation)
    @strategy.result(evaluation).to_h
  end
end

FactoryBot.register_strategy(:hash, HashStrategy)

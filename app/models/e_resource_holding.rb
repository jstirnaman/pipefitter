class EResourceHolding
  include SerialsSolutions
  attr_reader :kb_holdings
  # @TODO: Still needs some refactoring to get to the point.
  # We need a single, generic holding record model.
  def initialize(q)
    @kb_holdings = SerialsSolutions::Openurl::Client.new(q)
  end
  
  
end
  
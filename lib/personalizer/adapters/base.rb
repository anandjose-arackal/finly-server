class Personalizer::Adapters::Base < BaseOperation
  attr_accessor :params

  def self.call(params)
    self.new(params).run
  end

  def initialize(params)
    self.params = params
  end

end
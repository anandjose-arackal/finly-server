class Personalizer::Adapters::Base < BaseOperation
  attr_accessor :op_instance

  def self.call(op_instance, user, params)
    self.new(op_instance, user, params).run
  end

  def initialize(op_instance, user, params)
    self.op_instance = op_instance
    self.user = user
    self.params = params
  end

end
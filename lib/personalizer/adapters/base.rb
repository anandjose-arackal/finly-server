class Personalizer::Adapters::Base < BaseOperation
  attr_accessor :params, :action, :entity

  def self.call(entity, action, params)
    self.new(entity, action, params).run
  end

  def initialize(entity, action, params)
    self.entity = entity
    self.action = action
    self.params = params
  end

end
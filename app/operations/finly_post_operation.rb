class FinlyPostOperation < BaseOperation
  attr_accessor :status, :object

  def self.call(object, payload, status)
    self.new(object, payload, status).run
  end

  def initialize(object, params, status)
    self.object = object
    self.status = status
    super(nil, params)
  end

end

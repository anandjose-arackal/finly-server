class BaseService
  attr_accessor :errors

  def initialize
    @errors = Array.new
  end
end
class ExpressionEvaluator::Context::Masters::Location < ExpressionEvaluator::Context::Base

  alias_method :location, :data

  def self.accept?(data=nil)
    data and data.class.name == ::BranchLocation.name
  end

  def name(options={})
    location.name
  end

  def code(options={})
    location.location_code
  end

  def to_s
    name
  end

end
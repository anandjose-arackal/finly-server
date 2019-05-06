class ExpressionEvaluator::Context::Masters::Department < ExpressionEvaluator::Context::Base

  alias_method :department, :data

  def self.accept?(data=nil)
    data and data.class.name == ::Department.name
  end

  def name(options={})
    department.name
  end

  def code(options={})
    department.department_code
  end

  def to_s
    name
  end

end
class Rules::Rule
  attr_accessor :input, :operator, :rule_value

  def initialize(input, operator, rule_value)
    self.input = input
    self.operator = operator
    self.rule_value = rule_value
  end

  Rules::Constants::LOGICAL_OPERATORS.each do |operator|
    define_method operator do |rule|
      Rules::Rule.new(self, operator, rule)
    end
  end

  def as_json(options = {})
    case options[:mode].to_s
    when 'json_logic'
      Rules::Adapters::JSONLogic.as_json(self)
    when 'ransack'
      Rules::Adapters::Ransack.as_json(self)
    else
      Rules::Adapters::Store.as_json(self)
    end
  end

  def as_store(options = {})
    json = as_json(mode: 'store')
    if json[:m].present?
      json = {g: {'0': json}}
    else
      json = {g: {'0': {m: 'and', c: {'0' => json}}}}
    end
    json
  end

  def as_ransack(options = {})
    json = as_json(mode: 'ransack')
    if json[:m].present?
      json = {g: {'0': json}}
    else
      json = {g: {'0': {m: 'and', c: {'0' => json}}}}
    end
    data = options[:data] || {}
    LiquidHelper.interpolate json, data
  end

  def as_json_logic(options = {})
    as_json(mode: 'json_logic')
  end

  def apply?(data)
    JSONLogic.apply(as_json_logic, data)
  end
end
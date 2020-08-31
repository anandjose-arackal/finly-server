class Rules::Rule
  attr_accessor :operator, :attribute, :values, :meta

  def initialize(operator, attribute: nil, value:)
    self.operator = operator
    self.attribute = attribute
    self.values = value
  end

  Rules::Constants::LOGICAL_OPERATORS.each do |operator|
    define_method operator do |*values|
      Rules::Rule.new(operator, attribute: self, value: values)
    end
  end

  def with_meta(meta = NoObject)
    self.meta = meta unless meta == NoObject
    self
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
    unless json[:m].present?
      json ={logic_type: "group", m: 'and', c: [json]}
    end
    json
  end

  def as_json_logic(options = {})
    as_json(mode: 'json_logic')
  end

  def as_ransack(options = {})
    json = as_json(mode: 'ransack')
    if json[:m].present?
      json = {g: {'0': json}}
    else
      json = {g: {'0': {logic_type: "group", m: 'and', c: [json]}}}
    end
    return json unless options.has_key?(:data)

    data = options[:data] || {}
    LiquidHelper.interpolate(json, data).as_json
  end

  def apply?(data)
    JSONLogic.apply(as_json_logic, data)
  end
end
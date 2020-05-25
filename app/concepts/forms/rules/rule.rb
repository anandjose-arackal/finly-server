class Forms::Rules::Rule
  attr_accessor :input, :operator, :rule_value

  def initialize(input, operator, rule_value)
    self.input = input
    self.operator = operator
    self.rule_value = rule_value
  end

  Forms::Rules::Constants::LOGICAL_OPERATORS.each do |operator|
    define_method operator do |rule|
      Forms::Rules::Rule.new(self, operator, rule)
    end
  end

  def as_json(options = {})
    if options[:mode].to_s == 'json_logic'
      return Forms::Rules::JSONLogic.as_json(self)
    end
    Forms::Rules::Ransack.as_json(self)
  end

  def as_ransack(options = {})
    json = as_json(mode: 'ransack')
    if json[:m].present?
      json = {g: json}
    else
      json = {g: {m: 'and', c: {'0' => json}}}
    end
    json
  end

  def as_json_logic(options = {})
    as_json(mode: 'json_logic')
  end

  def apply?(data)
    JSONLogic.apply(as_json_logic, data)
  end
end
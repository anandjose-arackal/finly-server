class Forms::Rules::Ransack

  def self.load(data)
    return data if data.nil? or data.is_a?(Forms::Rules::Rule)

    data = JSON.load(data) if data.is_a?(String)
    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    if Forms::Rules::Constants::LOGICAL_OPERATORS.include?(data[:m].to_s)
      rule = nil
      data[:c].each_pair do |pos, d|
        if rule.nil?
          rule = Forms::Rules::Ransack.load(d)
        else
          rule = rule.send(data[:m], Forms::Rules::Ransack.load(d))
        end
      end
      rule
    else
      attribute = data&.dig('a', '0', 'name')
      predicate = data&.dig('p')
      type = data&.dig('t')
      value = data&.dig('v', '0', 'value')
      formula = data&.dig('f')
      entity = data&.dig('e')
      Forms::Rules::Operator.new(attribute).send(predicate, type: type, value: value, formula: formula, entity: entity)
    end
  end

  def self.dump(rule)
    JSON.dump(as_json(rule))
  end

  def self.as_json(rule)
    if Forms::Rules::Constants::LOGICAL_OPERATORS.include?(rule.operator.to_s)
      {m: rule.operator, c: {'0' => rule.input.as_json(mode: "ransack"), '1' => rule.rule_value.as_json(mode: "ransack")}}
    else
      values = {}
      if rule.rule_value[:value].respond_to?(:each)
        rule.rule_value[:value].each_with_index { |val, index| values[index] = val }
      else
        values['0'] = {value: rule.rule_value[:value]}
      end
      {a: {'0': {name: rule.input[:entity]}}, p: rule.operator, t: rule.rule_value[:type], v: values, f: rule.rule_value[:formula], e: rule.rule_value[:entity]}
    end
  end

  protected


end
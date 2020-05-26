class Rules::Adapters::Ransack

  def self.load(data)
    return data if data.nil? or data.is_a?(Rules::Rule)

    data = JSON.load(data) if data.is_a?(String)
    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    data = data[:g] if data[:g].present?

    if Rules::Constants::LOGICAL_OPERATORS.include?(data[:m].to_s)
      rule = nil
      data[:c].each_pair do |pos, d|
        if rule.nil?
          rule = Rules::Adapters::Ransack.load(d)
        else
          rule = rule.send(data[:m], Rules::Adapters::Ransack.load(d))
        end
      end
      rule
    else
      attribute = data&.dig('a', '0', 'name')
      predicate = data&.dig('p')
      value = data&.dig('v', '0', 'value')
      formula = nil
      # Entity cannot be computed from ransack
      entity = nil
      if value and value.include?("{{") and value.include?("}}")
        formula = value
        value = nil
      end
      Rules::Operator.new(attribute).send(predicate, value: value, formula: formula, entity: entity)
    end
  end

  def self.dump(rule)
    JSON.dump(as_json(rule))
  end

  def self.as_json(rule)
    if Rules::Constants::LOGICAL_OPERATORS.include?(rule.operator.to_s)
      {m: rule.operator, c: {'0' => rule.input.as_json(mode: "ransack"), '1' => rule.rule_value.as_json(mode: "ransack")}}
    else
      values = {}
      if rule.rule_value[:value].respond_to?(:each)
        rule.rule_value[:value].each_with_index { |val, index| values[index] = {value: val} }
      else
        # case rule.rule_value[:type]
        # when FormRuleType.id_for(:value)
        #   value = rule.rule_value[:value]
        # when FormRuleType.id_for(:formula)
        #   value = rule.rule_value[:formula]
        # when FormRuleType.id_for(:entity)
        #   value = rule.rule_value[:entity]
        # when FormRuleType.id_for(:none)
        #   value = 1
        # else
        #   value = 1
        # end
        value = rule.rule_value[:value] || rule.rule_value[:formula] || rule.rule_value[:entity] || 1
        values['0'] = { value: value }
      end
      {a: {'0': {name: rule.input[:entity]}}, p: rule.operator, v: values}
    end
  end

end
class Forms::Rules::JSONLogic

  def self.load(data)
    return data if data.is_a?(Forms::Rules::Rule)

    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    data.each_pair do |operator, value|

      if Forms::Rules::Constants::LOGICAL_OPERATORS.include?(operator.to_s)
        return Forms::Rules::Rule.new(load(value[0]), operator, load(value[1]))
      else
        val = value.is_a?(Hash) ? nil : value[1]
        formula = value.is_a?(Hash) ? value[1]['var'] : nil
        return Forms::Rules::Operator.new(value[0]['var']).send(operator, value: val, formula: formula)
      end

    end
  end

  def self.dump(rule)
    JSON.dump(as_json_logic(rule))
  end

  def self.as_json(rule)
    json = {}
    json[rule.operator] = [build_json(rule.input), build_json(rule.rule_value)]
    json
  end

  protected

  def self.build_json(func)
    if func.class.name == Hash.name
      if func[:value].present?
        return func[:value]
      else
        return {var: (func[:formula] || func[:entity])}.as_json
      end
    end

    func.as_json(mode: "json_logic")
  end

end
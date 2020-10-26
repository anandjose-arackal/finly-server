class Rules::Adapters::JSONLogic

  def self.load(data)
    return data if data.is_a?(Rules::Rule)

    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    data.each_pair do |operator, value|

      if Rules::Constants::LOGICAL_OPERATORS.include?(operator.to_s)
        return Rules::Rule.new(load(value[0]), operator, load(value[1]))
      else
        val = value.is_a?(Hash) ? nil : value[1]
        formula = value.is_a?(Hash) ? value[1]['var'] : nil
        return Rules::Operator.new(value[0]['var']).send(operator, value: val, formula: formula)
      end

    end
  end

  def self.dump(rule)
    JSON.dump(as_json_logic(rule))
  end

  def self.as_json(rule)
    json = {}
    operator = Rules::Constants::MATH_PREDICATE_MAP[rule.operator.to_s] || rule.operator.to_s
    json[operator] = []
    json[operator] += [build_json(rule.attribute)] if rule.attribute.present?
    json[operator] += rule.values.map { |value| build_json(value) }
    json
  end

  protected

  def self.build_json(func)
    if func.class <= Hash
      if func[:value].present?
        return func[:value].to_s.strip
      else
        var = (func[:formula] || func[:entity] || func[:name]).to_s
        var = "form.#{var}".strip unless var.start_with?('form.') or var.start_with?('row.')
        return {var: var}.as_json
      end
    end

    func.as_json(mode: "json_logic")
  end

end
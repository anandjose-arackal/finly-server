class Rules::Adapters::Store

  def self.load(data)
    return data if data.nil? or data.is_a?(Rules::Rule)

    data = JSON.load(data) if data.is_a?(String)
    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    # data = data[:g] if data[:g].present?


    if Rules::Constants::LOGICAL_OPERATORS.include?(data[:m].to_s)
      rule = nil
      data[:c].each do |d|
        if rule.nil?
          rule = Rules::Adapters::Store.load(d)
        else
          rule = rule.send(data[:m], Rules::Adapters::Store.load(d))
        end
      end
      rule
    else
      attribute = data&.dig('a')
      predicate = data&.dig('p')
      values = data&.dig('v')
      Rules::Operator.new(attribute[:entity]).send(predicate, *values)
    end
  end

  def self.dump(rule)
    JSON.dump(as_json(rule))
  end

  def self.as_json(rule)
    json = {}
    if Rules::Constants::LOGICAL_OPERATORS.include?(rule.operator.to_s)
      json = {m: rule.operator, c: []}
      json[:c] << rule.attribute.as_json(mode: 'store') if rule.attribute.present?
      json[:c] += rule.values.map {|val| val.as_json(mode: 'store')}
    else
      json[:p] = rule.operator
      json[:a] = rule.attribute.as_json(mode: 'store')
      json[:v] = rule.values.map {|val| val.as_json(mode: 'store')}
    end
    # values = {}
    # if rule.rule_value[:value].respond_to?(:each)
    #   rule.rule_value[:value].each_with_index { |val, index| values[index] = {value: val} }
    # else
    #   values['0'] = {value: rule.rule_value[:value]}
    # end
    # {a: {'0': {name: rule.input[:entity]}}, p: rule.operator, t: rule.rule_value[:type], v: values, f: rule.rule_value[:formula], e: rule.rule_value[:entity]}
    json
  end

end
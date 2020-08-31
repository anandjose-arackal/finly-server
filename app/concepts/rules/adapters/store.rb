class Rules::Adapters::Store

  def self.load(data)
    return data if data.nil? or data.is_a?(Rules::Rule)

    data = JSON.load(data) if data.is_a?(String)
    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)

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
      attribute = data&.dig('a', '0', 'name')
      predicate = data&.dig('p')
      type = data&.dig('t')&.to_sym || :value
      values = data&.dig('v').map do |pos, val|
        {type => val[:value]}
      end
      Rules::Operator.new(attribute).send(predicate, *values)
    end
  end

  def self.dump(rule)
    JSON.dump(as_json(rule))
  end

  def self.as_json(rule)
    operator = Rules::Constants::MATH_PREDICATE_MAP[rule.operator.to_s] || rule.operator.to_s
    if Rules::Constants::PREDICATES.include?(operator)
      values_hash = {}
      raw_value = []
      type = :value
      rule.values.each_with_index { |val, index|
        value = 1
        if val.has_key?(:value)
          type = :value
          value = val[:value]
        elsif val.has_key?(:formula)
          type = :formula
          value = val[:formula]
        elsif val.has_key?(:entity)
          type = :entity
          value = val[:entity]
        end
        # value = val[:value] || val[:formula] || val[:entity] || 1
        values_hash[index.to_s] = {value: value}
        raw_value << value
      }
      json = {logic_type: 'condition', a: {'0': {name: rule.attribute[:name], ransacker_args: {filter_id: rule.attribute[:name]}}}, p: operator, v: values_hash, t: type.to_s, raw_value: raw_value}

      # Fixme: FE is currently build to parse auto_complete keyword, hence maintaining it here
      if rule.meta.present?
        json[:auto_complete] = rule.meta
      end

      json
    else
      json = {logic_type: 'group', m: operator, c: []}
      if rule.attribute.present?
        json[:c] << rule.attribute.as_json(mode: 'store')
      end
      rule.values.each_with_index do |value, index|
        json[:c] << value.as_json(mode: 'store')
      end
      json
    end
  end

end
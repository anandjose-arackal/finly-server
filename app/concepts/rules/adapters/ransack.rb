class Rules::Adapters::Ransack

  def self.load(data)
    return data if data.nil? or data.is_a?(Rules::Rule)

    data = JSON.load(data) if data.is_a?(String)
    data = data.with_indifferent_access unless data.is_a?(ActiveSupport::HashWithIndifferentAccess)
    data = data.dig('g', '0') if data['g'].present?

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
    operator = Rules::Constants::MATH_PREDICATE_MAP[rule.operator.to_s] || rule.operator.to_s
    if Rules::Constants::PREDICATES.include?(operator)
      values_hash = {}
      raw_value = []
      rule.values.each_with_index { |val, index|
        value = val[:value] # || val[:formula] || val[:entity] || 1
        value ||= val[:formula]
        value ||= "{{form.#{val[:entity]}}}" if val[:entity].present?
        value ||= 1
        values_hash[index.to_s] = {value: value}
        raw_value << value
      }
      json = {logic_type: 'condition', a: {'0': {name: rule.attribute[:name], ransacker_args: {filter_id: rule.attribute[:name]}}}, p: operator, v: values_hash, raw_value: raw_value}

      # Fixme: FE is currently build to parse auto_complete keyword, hence maintaining it here
      if rule.meta.present?
        json[:auto_complete] = rule.meta
      end

      json
    else
      json = {logic_type: 'group', m: operator, c: {}}
      pos = 0
      if rule.attribute.present?
        json[:c][pos.to_s] = rule.attribute.as_json(mode: 'ransack')
        pos += 1
      end
      rule.values.each_with_index do |value, index|
        json[:c][(index + pos).to_s] = value.as_json(mode: 'ransack')
      end
      json
    end
  end

end
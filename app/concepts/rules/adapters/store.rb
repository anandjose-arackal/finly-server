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
      meta = data&.dig('m')
      Rules::Operator.new(attribute[:entity]).send(predicate, *values).with_meta(meta)
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
      json[:m] = rule.meta
    end
    json
  end

end
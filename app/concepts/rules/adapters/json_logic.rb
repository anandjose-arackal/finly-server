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

  def self.as_json(rule, options = {})
    if rule.attribute.is_a?(Rules::Rule) #handle incase of nested rules (to support :some for nested rules)
      json_logic_attribute = self.as_json(rule.attribute, options)
      json_logic_value = rule.values.map { |value| self.as_json(value, options) }
      json = {}
      operator = Rules::Constants::MATH_PREDICATE_MAP[rule.operator.to_s] || rule.operator.to_s
      json[operator] = []
      json[operator] += [json_logic_attribute]
      json[operator] += json_logic_value
      json
    else
      json = self.as_json_data(rule, options) #incase of simple rule process as usual
    end
    json
  end

  def self.as_json_data(rule, options = {})
    json_logic_type = self.json_logic_type(rule, options)
    return {} if json_logic_type == :invalid
    json = {}
    operator = Rules::Constants::MATH_PREDICATE_MAP[rule.operator.to_s] || rule.operator.to_s
    json[operator] = []
    json[operator] += [build_var(rule.attribute, json_logic_type, options)] if rule.attribute.present?
    values = rule.values.map { |value| build_var(value, json_logic_type, options) }
    if values.size == 1
      json[operator] += values
    else
      json[operator] << values
    end

    if json_logic_type == :some
      json = { 'some' => [{ 'var' => "form.#{collection_association_name(options[:model_klass], rule.attribute[:name])}" }, json] }
    end
    json
  end

  # This is responsible for validating the rule with json_logic standards
  def self.valid?(rule, options = {})
    return true unless rule.is_a?(Rules::Rule)

    json_logic_type = self.json_logic_type(rule, options)
    return false if json_logic_type == :invalid

    return false unless valid?(rule.attribute, options)

    rule.values.each do |value|
      return false unless valid?(value, options)
    end

    true
  end

  protected

  def self.build_var(func, json_logic_type, options = {})
    prefix_map = { form: 'form.', row: 'row.', some: nil }.with_indifferent_access

    if func.class <= Hash
      prefix = prefix_map[json_logic_type]

      # if func[:value].present? or func[:formula].present?

      if func.keys.include?(:value) or func.keys.include?(:formula)
        return func[:value]&.to_s&.strip || func[:formula]&.to_s&.strip
      else
        # Name is for source attribute, where as value, formula and entity is for value attribute
        var = (func[:entity] || func[:name]).to_s
        unless var.start_with?('form.') or var.start_with?('row.')
          var = var.split('.').last unless json_logic_type == :form
          var = "#{prefix}#{var}".strip
        end
        return { var: var }.as_json
      end
    end
    func.as_json(mode: 'json_logic')
  end

  # - With Controlling Field
  #     - Form -> When Source/Value are not in line item
  #         - Controlling Field: Line Item, Source/Value: Header
  #         - Controlling Field: Header, Source/Value: Header
  #     - Row -> When Source/Value and controlling field are in the same line item
  #         - Controlling Field: Line Item, Source/Value: Line Item
  #     - Some -> When Source/Value and controlling field are in different line items
  #         - Controlling Field: Header, Source/Value: Line Item
  #         - Controlling Field: Line Item, Source/Value: Different Line Item
  # - Without Controlling Field
  #     - Form
  #         - Source/Value: Header
  #     - Some
  #         - Source/Value: Line Item
  def self.json_logic_type(rule, options = {})
    return :none if rule.attribute.is_a?(Rules::Rule)
    model_klass = options[:model_klass]
    controller = options[:controlling_field]
    controller_collection_parent = collection_association_name(model_klass, controller)
    source = rule.attribute[:name]
    source_collection_parent = collection_association_name(model_klass, source)
    value = rule.values.first[:entity]
    value_collection_parent = collection_association_name(model_klass, value)

    return :invalid if value.present? and source_collection_parent != value_collection_parent

    if controller.present?
      # If source and value are not in line item
      return :form if source_collection_parent.blank?

      # If controller_collection_parent, source_collection_parent and value_collection_parent are in the same line item
      return :row if controller_collection_parent == source_collection_parent

      # If controller_collection_parent and source_collection_parent/value_collection_parent belong to different line items
      return :some if controller_collection_parent != source_collection_parent
    else
      # If controller_collection_parent and source_collection_parent/value_collection_parent belong to different line items
      return :some if source_collection_parent.present?

      # If source and value are not in line item
      return :form
    end
  end

  # This is responsible for fetching the association parent name for the attribute from the model
  def self.collection_association_name(model_klass, attribute)
    return nil if attribute.nil?
    return nil if model_klass.blank? or not attribute.include?('.')
    return nil if attribute.start_with?('form.') or attribute.start_with?('row.')

    association = attribute.split('.').first
    has_many_associations = model_klass.reflect_on_all_associations(:has_many).map(&:name)
    return association if has_many_associations.include?(association.to_sym)

    nil
  end

end



class Rules::Adapters::Grammar

  def self.load(data)
    if data.is_a?(Hash)
      if data[:commands]
        load(data[:commands])
      elsif data[:expressions]
        load(data[:expressions])
      elsif data[:condition]
        load(data[:condition])
      elsif data[:paren_expression]
        load(data[:paren_expression])
      elsif data[:function_call]
        name = data[:function_call][:name]
        variables = data[:function_call][:variable_list][:paren_list].map { |var| load(var) }
        return Rules::Rule.new(name.to_s.downcase, value: variables)
      elsif data[:left]
        left = load(data[:left])
        return left unless (ops = data[:ops]).present?

        attribute = nil
        values = []

        # Todo check if attribute / value
        left_attr = to_value(left)
        if left_attr.class.name == Rules::Rule.name
          values << left_attr
        elsif left_attr[:entity].present?
          attribute = left_attr
        else
          values << left_attr
        end

        ops.each do |op|
          operator = op[:operator].to_s

          if Rules::Constants::LOGICAL_OPERATORS.include?(operator.to_s)

          else

          end

          right = load(op[:right])
          if right.respond_to?(:each)
            values += right.map { |val| to_value(val) }
          else
            values << to_value(right)
          end
          return Rules::Rule.new(operator.to_s.downcase, attribute: attribute, value: values)
        end
      elsif data[:number]
        return load(data[:number])
      elsif data[:variable]
        return load(data[:variable])
      else
        nil
      end
    elsif [String.name, Parslet::Slice.name].include?(data.class.name)
      # if data.to_s.start_with?("$")
      #   {var: data.gsub("$", "").to_s.strip}
      # else
      data.to_s
      # end
    else
      data
    end
  end

  # In case the attribute (left) is being set, then it cannot be a value or a formula. It has to be an entity
  def self.to_value(value)
    return value unless value.class.name == String.name

    # if attribute
    #   return {entity: value.sub("$", "").squish}
    if value&.start_with?("$form.") or value&.start_with?("$row.") or value&.start_with?("$parent.")
      return {formula: value.sub("$", "").squish}
    elsif value&.start_with?("$")
      return {entity: value.sub("$", "").squish}
    end

    {value: value.squish}
  end

end
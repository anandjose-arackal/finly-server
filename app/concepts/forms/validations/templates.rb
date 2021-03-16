class Forms::Validations::Templates

  def self.[](key)
    validates[key]
  end

  def self.validates(key = NoObject, &block)
    @validates ||= {}
    @validates[key] = block if key != NoObject and block_given?
    @validates
  end

  validates :regex_match do |contract:, entity:, **|
    format = entity.options['regex']&.dig('format')
    message = entity.options['regex']&.dig('message')

    if format.present?
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?

        match_data = value.match(Regexp.new(format))

        unless match_data.present? && match_data[0] == value
          if (message).present?
            errors.add entity.label, message
          else
            errors.add entity.label, "did not match format : #{format}"
          end
        end
      end
    end
  end

  validates :max_value do |contract:, entity:, **|
    if entity.options['max_value'].present?
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?

        value = Float(value) rescue nil

        if value.nil?
          errors.add entity.label, "must be numeric"
        else
          if value > entity.options['max_value']
            errors.add entity.label, "must be less than or equal to #{entity.options['max_value']}"
          end
        end
      end
      # contract.validates entity.entity_key.to_sym, numericality: {less_than_or_equal_to: entity.options['max_value']}
    end
  end

  validates :min_value do |contract:, entity:, **|
    if entity.options['min_value'].present?
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?

        value = Float(value) rescue nil

        if value.nil?
          errors.add entity.label, "must be numeric"
        else
          if value < entity.options['min_value']
            errors.add entity.label, "must be greater than or equal to #{entity.options['min_value']}"
          end
        end
      end
      # contract.validates entity.entity_key.to_sym, numericality: {greater_than_or_equal_to: entity.options['min_value']}
    end
  end

  validates :minimum do |contract:, entity:, **|
    if entity.options['minimum'].present? and entity.options['minimum'].to_i > 0
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?
        if entity.entity_type == 'attachment'
          valid_attachments = value.filter {|item| !item[:_destroy]}
          next if valid_attachments.length.zero? && !entity.required
          if valid_attachments.length < entity.options['minimum'].to_i
            errors.add entity.label, "is less than the minimum (minimum is #{entity.options['minimum']} attachments)"
          end
        else
          if value.length < entity.options['minimum'].to_i
            errors.add entity.label, "is too short (minimum is #{entity.options['minimum']} characters)"
          end
        end
      end
    end
  end

  validates :maximum do |contract:, entity:, **|
    if entity.options['maximum'].present? and entity.options['maximum'].to_i > 0
      contract.validate do
        value = send(entity.entity_key)
        next unless value.present?
        if entity.entity_type == 'attachment'
          valid_attachments = value.filter {|item| !item[:_destroy]}
          next if valid_attachments.length.zero? && !entity.required
          if valid_attachments.length > entity.options['maximum'].to_i
            errors.add entity.label, "is more than the maximum (maximum is #{entity.options['maximum']} attachments)"
          end
        else
          if value.length > entity.options['maximum'].to_i
            errors.add entity.label, "is too long (maximum is #{entity.options['maximum']} characters)"
          end
        end
      end
    end
  end

  validates :min_items do |contract:, entity:, **|
    if entity.options['min_items'].present? and entity.options['min_items'].to_i > 0
      contract.validate do
        value = send(entity.entity_key)
        if value.length < entity.options['min_items'].to_i
          errors.add entity.label, "must have atleast #{entity.options['min_items'].to_i} record"
        end
      end
    end
  end

  validates :choices do |contract:, entity:, **|

  end

end
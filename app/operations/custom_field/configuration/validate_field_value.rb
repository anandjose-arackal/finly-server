class CustomField::Configuration::ValidateFieldValue < CustomField::Configuration::Base
  attr_accessor :value, :key, :config

  def pre_validate
    if params.blank?
      add_message :error, 'Nothing to validate'
      return
    end
    if params[:type_id].blank?
      add_message :error, 'Invalid Configuration. Type ID not found'
    end
    if params[:config].blank?
      add_message :error, 'Invalid Configuration. Configuration not found'
    end
  end

  def init
    self.value = params[:value]
    self.config = params[:config]
    self.key = FieldType.name_for(config.field_type_id) if config.present?
  end

  def validate
    if self.config.blank?
      add_message :error, 'Invalid Configuration. Configuration not found'
      return
    end
    if value.blank?
      add_message :error, "#{field_name}'s value cannot be empty"
    end
    if key.blank?
      add_message :error, "#{field_name}'s type is invalid"
    end
  end

  def process
    case key
      when :text
      when :number
        return if Integer (value) rescue nil
        add_message :error, 'Given value is not a valid number'
      when :decimal
        return if Float (value) rescue nil
        add_message :error, 'Given value is not a valid decimal number'
      when :boolean
        return unless StringUtils.to_bool(value).nil?
        add_message :error, 'Given value is not a boolean'
      when :drop_down
        return if Integer (value) and config.drop_down_items.with_id(value).present? rescue nil
        add_message :error, 'Selected item not found within the scope of the drop-down'
      when :date
        # Validates date format for 12 Apr 2011
        return if Date.strptime(value, "%d %b %Y") rescue nil
        add_message :error, 'Given date is not a valid date format'
      when :amount
        # Amount validation is Not required as Amount model would be handling the validation
    end
  end

end
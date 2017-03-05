class CustomField::Validate < CustomField::Base
  attr_accessor :field

  def pre_validate
    if params.blank?
      add_message :error, 'Configuration not loaded correctly'
      return
    end
    if params[:field].blank? and params[:custom_field].blank?
      add_message :error, 'Configuration not loaded correctly. Field not found'
    end
  end

  def init
    self.field = params[:field] or params[:custom_field]
  end

  def validate
    if field.blank? or not field.kind_of?(CustomField)
      add_message :error, 'Configuration not loaded correctly. Field not found'
    end
  end

  def process
    config = field.field_configuration
    # Validate if mandatory value is present
    if field.value.blank?
      # If mandatory field value is blank, show error
      if config.mandatory
        if config.field_type_id == FieldType.id_for(:drop_down)
          add_message :error, "#{config.field_name} has not been selected"
        else
          add_message :error, "#{config.field_name} cannot be blank"
        end
      end
      # Return if value is empty as no further validation is required
      return
    end
    result = CustomField::Configuration::ValidateFieldValue.(value: field.value, config: config)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
  end

end
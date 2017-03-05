class CustomField::Configuration::ValidateFieldValue < CustomField::Configuration::Base
  attr_accessor :type_id, :value, :key, :field_name
  
  def self.call(params)
    self.new(params).run
  end
  
  def initialize(params)
    super(nil, params)
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Nothing to validate'
      return
    end
    if params[:type_id].blank?
      add_message :error, 'Invalid Configuration. Type ID not found'
    end
    if params[:field_name].blank?
      add_message :error, 'Invalid Configuration. Field name cannot be empty'
    end
  end

  def init
    self.field_name = params[:field_name]
    self.type_id = params[:type_id]
    self.value = params[:value]
    self.key = FieldType.name_for(type_id)
  end

  def validate
    if field_name.blank?
      add_message :error, 'Invalid Configuration. Field name cannot be empty'
      return
    end
    if type_id.blank?
      add_message :error, "'Invalid Configuration. #{field_name}'s Type ID not found'"
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
      when :dropdown
        return if Integer (value) and FieldDropDownItem.with_id(value).present? rescue nil
        add_message :error, 'Selected item not found within the scope of the dropdown'
      when :date
        # Validates date format for 12 Apr 2011
        return if Date.strptime(value, "%d %b %Y") rescue nil
        add_message :error, 'Given date is not a valid date format'
      when :amount
        return if Integer (value) and Amount.with_id(value).present? rescue nil
        add_message :error, 'Entered amount is invalid format'
    end
  end

end
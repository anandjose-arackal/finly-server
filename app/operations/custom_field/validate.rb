class CustomField::Validate < CustomField::Base
  attr_accessor :item, :custom_fields

  def self.call(item, params= {})
    self.new(item, params).run
  end


  def initialize(item, params= {})
    super(nil, params)
    self.item = item
  end

  def pre_validate
    if self.item.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def init
    self.custom_fields = self.item.custom_fields rescue nil
  end

  def process
    return if self.custom_fields.blank?

    self.custom_fields.each do |field|
      if field.field_configuration.mandatory and field.value.blank?
        add_message :error, "#{field.field_configuration.field_name} cannot be empty"
      end
    end
  end

end
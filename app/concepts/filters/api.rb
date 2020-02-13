class Filters::API
  include DynamicAttributes

  class_attr :attributes, default: {}

  # Check if the attribute is defined
  def self.exists?(filter_key)
    attributes[filter_key].present?
  end

  def self.attribute(field_key, label: nil, type: :text, hint: "Select Value", scope: nil)
    raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

    label ||= field_key.to_s.humanize

    attributes[field_key] = Attribute.new(
        {
            field_key: field_key,
            label: label,
            field_type: type,
            hint: hint,
            scope: scope
        }
    )
  end

  def self.build
    filters = []
    attributes.each do |field_key, attribute|
      filters << attribute.build
    end
    filters
  end


end
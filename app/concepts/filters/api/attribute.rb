class Filters::API::Attribute

  attr_accessor :field_key, :label, :field_type, :choices, :hint, :simple, :custom_field_id

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  # Simple is used to identify if the filter should be a part of the simple filter or not
  def initialize(field_key:, label:, hint:, field_type:, choices: nil, simple: false, custom_field_id: nil)
    self.field_key = field_key
    self.label = label
    self.hint = hint
    self.field_type = field_type
    self.choices = choices
    self.simple = simple
    self.custom_field_id = custom_field_id
  end

  def operators
    op = Forms::API::Entity::Registry.types[field_type].operators

    # as the ransacker :custom_fields_value_search has issues with not query, remove all not conditions
    return op.reject { |o| o.to_s.start_with?("not_") } if custom_field_id.present?

    op
  end

  def build(user)
    params = {
        field_key: field_key,
        label: label,
        hint: hint,
        field_type: field_type,
        simple: simple,
        operators: operators,
        args: {filter_id: field_key}
    }
    if custom_field_id.present?
      # Generate unique ID for custom fields
      params[:args] = {field_id: "#{field_key}_#{custom_field_id}", custom_field_id: custom_field_id}
    end

    if choices.present?
      choices_data = choices.build(user: user)
      # If the choices is partial, then set the field type as lookup.
      if StringUtils.to_bool(choices_data[:partial]) and field_type.to_s == 'dropdown'
        params[:field_type] = :lookup
      end

      params[:choices] = choices_data[:choices]
    end
    params
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      class_attr :attributes, default: {}.with_indifferent_access
    end

    class_methods do
      # Check if the attribute is defined
      def exists?(filter_key)
        attributes[filter_key].present?
      end

      def attribute(field_key, label: nil, type: :text, hint: "Select Value", choices: nil, simple: false)
        raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

        label ||= field_key.to_s.humanize

        attributes[field_key] = Filters::API::Attribute.new(
            {
                field_key: field_key,
                label: label,
                field_type: type,
                hint: hint,
                choices: choices,
                simple: simple
            }
        )
      end

      def build(user)
        filters = []
        attributes.each do |field_key, attribute|
          filters << attribute.build(user)
        end
        filters
      end
    end
  end

end
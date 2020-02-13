class Filters::API::Attribute

  attr_accessor :field_key, :label, :field_type, :scope, :hint

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(field_key:, label:, hint:, field_type:, scope: nil)
    self.field_key = field_key
    self.label = label
    self.hint = hint
    self.field_type = field_type
    self.scope = scope
  end

  def operators
    Forms::API::Entity::Registry.types[field_type].operators
  end

  def build(user)
    params = {
        field_key: field_key,
        label: label,
        hint: hint,
        field_type: field_type,
        operators: operators
    }
    params[:scope] = scope if scope
    params
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      class_attr :attributes, default: {}
    end

    class_methods do
      # Check if the attribute is defined
      def exists?(filter_key)
        attributes[filter_key].present?
      end

      def attribute(field_key, label: nil, type: :text, hint: "Select Value", scope: nil)
        raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

        label ||= field_key.to_s.humanize

        attributes[field_key] = Filters::API::Attribute.new(
            {
                field_key: field_key,
                label: label,
                field_type: type,
                hint: hint,
                scope: scope
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
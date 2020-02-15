class IndexBuilder::API::Attribute
  attr_accessor :field_key, :label, :template, :default, :sort, :includes, :fixed

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(params)
    params.each_pair do |key, value|
      send(:"#{key}=", value)
    end
  end

  def config(user)
    {
        field_key: field_key,
        label: label,
        type: template.handle,
        sort: sort,
        default: default,
    }
  end

  def build(context, user, record)
    template.build(context, user, record)
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      include DynamicAttributes

      class_attr :attributes, default: {}
      class_attr :fixed_attribute
    end

    class_methods do
      # Check if the attribute is defined
      def exists?(field_key)
        attributes[field_key].present?
      end

      def attribute(field_key, default: false, label: nil, sort: false, template:, includes: [], fixed: false)
        raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

        label ||= field_key.to_s.humanize

        attribute = IndexBuilder::API::Attribute.new(
            {
                field_key: field_key,
                label: label,
                sort: sort,
                includes: includes,
                default: default,
                template: template,
                fixed: fixed
            }
        )

        fixed_attribute(attribute) if fixed
        attributes[field_key] = attribute
      end
    end
  end

end
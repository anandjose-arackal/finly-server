class IndexBuilder::API::Attribute
  attr_accessor :field_key, :label, :template, :default, :sort, :includes

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(field_key:, label:, default:, sort:, template:, includes:)
    self.field_key = field_key
    self.label = label
    self.template = template
    self.sort = sort
    self.default = default
    self.includes = includes
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
    template.build(context,user, record)
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      include DynamicAttributes

      class_attr :attributes, default: {}
    end

    class_methods do
      # Check if the attribute is defined
      def exists?(field_key)
        attributes[field_key].present?
      end

      def attribute(field_key, default: false, label: nil, sort: false, template:, includes: [])
        raise "#{field_key} is already defined for class #{self.name}" if exists?(field_key)

        label ||= field_key.to_s.humanize

        attributes[field_key] = IndexBuilder::API::Attribute.new(
            {
                field_key: field_key,
                label: label,
                sort: sort,
                includes: includes,
                default: default,
                template: template,
            }
        )
      end
    end
  end

end
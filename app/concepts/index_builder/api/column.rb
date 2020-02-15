class IndexBuilder::API::Column
  attr_accessor :column_key, :label, :template, :default, :sort, :includes, :fixed

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(params)
    params.each_pair do |key, value|
      send(:"#{key}=", value)
    end
  end

  def config(user)
    {
        column_key: column_key,
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

      class_attr :columns, default: {}
      class_attr :fixed_column
    end

    class_methods do
      # Check if the column is defined
      def exists?(column_key)
        columns[column_key].present?
      end

      def column(column_key, default: false, label: nil, sort: false, template:, includes: [], fixed: false)
        raise "#{column_key} is already defined for class #{self.name}" if exists?(column_key)

        label ||= column_key.to_s.humanize

        column = IndexBuilder::API::Column.new(
            {
                column_key: column_key,
                label: label,
                sort: sort,
                includes: includes,
                default: default,
                template: template,
                fixed: fixed
            }
        )

        fixed_column(column) if fixed
        columns[column_key] = column
      end
    end
  end

end
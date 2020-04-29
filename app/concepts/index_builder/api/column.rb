class IndexBuilder::API::Column
  include IndexBuilder::ContentTypes::Registry
  include ActionManager::DSL

  attr_accessor :column_key, :label, :default, :sort, :includes, :fixed, :block

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(params)
    params.each_pair do |key, value|
      send(:"#{key}=", value)
    end

    instance_eval &block if block.present?
  end

  def sort
    sort_key = @sort
    sort_key == true ? self.column_key : sort_key
  end

  def fields
    @fields ||= []
  end

  def field(*args)
    opts = args.extract_options!
    klass = IndexBuilder::ContentTypes::Registry.types[args.first]
    field = klass.new(opts)
    fields << field
  end

  def config(user)
    {
        column_key: column_key,
        label: label,
        sort: sort,
        default: default,
    }
  end

  def build(context, user, record, record_exposure)
    values = []
    fields.each do |field|
      values << field.build(context, user, record, record_exposure)
    end
    actions.each do |id, action|
      next unless action.authorized?(current_user: user, record: record)

      values << {content_type: 'action'}.merge(action.build(current_user: user, params: {}))
    end
    values
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

      def column(column_key, default: false, label: nil, sort: false, includes: [], fixed: false, fields: [], &block)
        raise "#{column_key} is already defined for class #{self.name}" if exists?(column_key)
        raise "#{column_key} does not have associated fields" unless block_given? or fields.present?

        if not block_given? and fields.present?
          block = lambda do |*args|
            fields.each do |field_value|
              field :text, value: field_value
            end
          end
        end

        label ||= column_key.to_s.humanize

        column = IndexBuilder::API::Column.new(
            {
                column_key: column_key,
                label: label,
                sort: sort,
                includes: includes,
                default: (default || fixed),
                fixed: fixed,
                block: block
            }
        )

        fixed_column(column) if fixed
        columns[column_key] = column
      end

      def custom_fields(*type, path: nil, includes: [:custom_fields])
        if type.present?
          path ||= lambda do |record|
            record.custom_fields
          end
          @custom_fields = {type: type, path: path, includes: includes}
        end
        @custom_fields
      end
    end
  end

end
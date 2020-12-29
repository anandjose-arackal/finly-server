class Drawer::API::Block
  include IndexBuilder::ContentTypes::Registry
  include ActionManager::DSL

  attr_accessor :block_key, :label, :default,  :code_block, :icon

  # Includes: Used for capturing the data points to be included to optimize the fetch for the current record
  def initialize(params)
    params.each_pair do |key, value|
      send(:"#{key}=", value)
    end

    instance_eval &code_block if code_block.present?
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
        block_key: block_key,
        label: label,
        icon:icon
    }
  end

  def build(context, user, record, record_exposure)
    map ={
        label: self.label,
        icon: self.icon
    }
    values = []
    fields.each do |field|
      values << field.build(context, user, record, record_exposure)
    end
    map[:content] =values
    map
  end

  module Builder
    extend ActiveSupport::Concern

    included do
      include DynamicAttributes

      class_attr :blocks, default: {}
    end

    class_methods do

      def block(block_key: nil,label: nil, icon: nil, &code_block)
        if not block_given? and fields.present?
          code_block = lambda do |*args|
            fields.each do |field_value|
              field :text, value: field_value
            end
          end
        end

        label ||= block_key.to_s.humanize
        block = Drawer::API::Block.new(
            {
                block_key: block_key,
                label: label,
                icon: icon,
                code_block: code_block
            }
        )

        blocks[block_key] = block
      end

    end
  end

end
class Masters::API
  include DynamicAttributes

  class_attr :model

  def self.schema(args = {}, &block)
    @schema ||= MasterSchema.new(args)
    @schema.instance_eval &block if block_given?
    @schema
  end
end
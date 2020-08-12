class Masters::API
  include DynamicAttributes

  class_attr :model
  class_attr :display_name

  def self.name(name = NoObject)
    @name = name unless name == NoObject
    @name ||= model&.name
  end

  def self.schema(args = {}, &block)
    args[:name] = name
    args[:master_key] = model.table_name
    args[:model] = model
    args[:klass_name] = self
    args[:display_name] = self.display_name
    @schema ||= MasterSchema.new(args)
    @schema.instance_eval &block if block_given?
    @schema
  end
end
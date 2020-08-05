class Masters::API
  include DynamicAttributes

  def self.model(model = NoObject)
    @model = model unless model == NoObject
    @model
  end

  def self.name(name = NoObject)
    @name = name unless name == NoObject
    @name || model&.name
  end

  def self.schema(args = {}, &block)
    args[:name] = name
    args[:table_name] = model.table_name
    @schema ||= MasterSchema.new(args)
    @schema.instance_eval &block if block_given?
    @schema
  end
end
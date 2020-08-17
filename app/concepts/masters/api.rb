class Masters::API
  include DynamicAttributes

  class_attr :model

  def self.name(name = NoObject)
    @name = name unless name == NoObject
    @name ||= model&.name
  end

  def self.schema(args = {}, &block)
    raise "Model not defined" if model.blank?

    args[:name] = name
    args[:master_key] = model.table_name
    args[:model] = model
    args[:klass_name] = self
    args[:system_master] = true
    @schema ||= MasterSchema.new(args)
    @schema.instance_eval &block if block_given?
    contract = Masters::Schema::Contract.new(@schema)
    raise "Invalid Master Schema: #{contract.errors}" unless contract.validate({})
    contract.sync

    @schema
  end
end
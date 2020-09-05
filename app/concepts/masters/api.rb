# Masters::API is the base class which provides the DSL for defining system masters
#
# === Example
# Reference is from {Masters::Categories::Master}
#   class Masters::Categories::Master < Masters::API
#
#     model Category
#
#     schema do
#       sequence :category_code, prefix: "CAT/", min_length: 6, show_in_lookup: true
#       parent_lookup
#       text :name, required: true, show_in_lookup: true, unique: true, primary_key: true
#       text :gl_code, show_in_lookup: true
#       date :start_date
#       date :end_date
#     end
#
#   end
#
class Masters::API
  include DynamicAttributes

  # @!attribute [rw]
  #   @return ApplicationRecord
  class_attr :model

  # Used for defining the name of the master. This defaults to the model name unless its defined
  #
  # @param [String] name
  #   Used for assigning the name of the master.
  #
  # @return [String, nil]
  #     Returns the name of the master. If the name is not explicitly assigned,
  #     it returns the name of the model
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
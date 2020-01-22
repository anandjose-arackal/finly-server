module Forms::Entity::Schema
  extend ActiveSupport::Concern

  included do
    include DynamicAttributes
  end

  class_methods do
    def schema
      return @class_schema if @class_schema

      if self == Forms::Entity::Base
        @class_schema ||= {options: {}}
      else
        @class_schema ||= Forms::Entity::Base.schema.deep_dup
      end
    end

    # Attribute is saved directly to the model and is comment for all types
    def attribute(key, default: nil)
      schema[key] = default
      define_method key do |value = NoObject|
        self.schema_builder[key] = value unless value == NoObject
        Transactions::Helper.execute_if_proc(self, schema_builder[key])
      end
      alias_method "#{ key }=", key

      define_singleton_method key do |value = NoObject|
        schema[key] = value unless value == NoObject
        schema[key]
      end
    end

    # Options are type specific attributes
    def option(key, default: nil)
      schema[:options][key] = default if default
      define_method key do |value = NoObject|
        self.schema_builder[:options][key] = value unless value == NoObject
        Transactions::Helper.execute_if_proc(self, schema_builder[:options][key])
      end
      alias_method "#{ key }=", key

      define_singleton_method key do |value = NoObject|
        schema[:options][key] = value unless value == NoObject
        schema[:options][key]
      end
    end

    def consumes_choices?
      @consumes_choices ||= false
    end

    def consumes_choices!
      @consumes_choices = true
    end

    def valid_schema?(schema)
      contract = self.contract.new
      result = contract.call(schema)
      if result.failure?
        return Failure(result.errors.to_h)
      end
      Success(schema)
    end

  end

  def schema_builder
    @schema_builder ||= self.class.schema.deep_dup
  end

  def schema
    return @schema if @schema

    @schema = {options: {}}
    schema_builder.except(:options).keys.each do |key|
      @schema[key] = self.send(key)
    end

    schema_builder[:options].keys.each do |key|
      @schema[:options][key] = self.send(key)
    end

    if self.class.consumes_choices? and schema_builder[:choices].present?
      @schema[:choices] = schema_builder[:choices].build
    end

    @schema
  end

  def choices(values = NoObject)
    return nil unless self.class.consumes_choices?

    @choices ||= []
    unless values == NoObject
      @choice_position ||= 0
      values.each do |value|
        raise "Invalid choice #{value}" unless value[:value].present? and value[:name].present?
        value[:active] ||= true
        value[:position] = @choice_position
        @choices << value.slice(:value, :name, :active, :position)
        @choice_position += 1
      end
    end
    @choices
  end

  alias_method :choices=, :choices

  def scope(value = NoObject)
    return nil unless self.class.consumes_choices?

    @scope = value unless value == NoObject
    @scope
  end
  alias_method :scope=, :scope

  # def auto_complete(route: nil, filters: {})
  #   return nil unless self.class.consumes_choices?
  #
  #   @auto_complete = {route: route, filters: filters} if route
  #   @auto_complete
  # end
  #
  # alias_method :auto_complete=, :auto_complete

  def valid?
    self.class.valid_schema?(self.schema)
  end
end
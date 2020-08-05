module Masters::Entity::Registry
  extend ActiveSupport::Concern

  def self.types
    @types ||= {}.with_indifferent_access
  end

  def self.register(klass, type)
    klass.registered_type(type)
    Masters::Entity::Registry.types[type] = klass

    Masters::Entity::Registry.module_eval do
      define_method type do |*args|
        opts = args.extract_options!
        entity_key = args.first
        entity type, entity_key, opts
      end
    end
  end

  def entity(type, entity_key, opts={})
    klass = Masters::Entity::Registry.types[type]
    raise "Invalid type #{type}" if klass.nil?

    entity = klass.new(master_schema: self)
    contract = Masters::Entity::Contract::System.new(entity)
    params = klass.schema.deep_dup
    params[:position] = entities.size
    params[:entity_key] = entity_key
    unless contract.validate(params.deep_merge(opts))
      raise "Invalid MasterEntity: #{self}##{entity_key} (#{klass}) Failure: #{contract.errors.full_messages}"
    end
    contract.sync

    entities << entity
  end
end

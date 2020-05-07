module Forms::API::Entity::Registry
  extend ActiveSupport::Concern

  def self.types
    @types ||= {}.with_indifferent_access
  end

  def find_entity(entity_path)
    self.entities.each do |entity|
      return entity if entity.entity_path == entity_path

      entity.entities.each do |sub_entity|
        return sub_entity if sub_entity.entity_path == entity_path

        matching_entity = sub_entity.find_entity(entity_path)
        return matching_entity if matching_entity
      end
    end
    nil
  end

  def entities
    @entities ||= []
  end

  def entity(*args, &block)
    opts = args.extract_options!
    klass, name = klass_and_name_from args
    entity = klass.new(section, name, entity_path, opts, &block)
    result = entity.valid?
    unless result.success?
      raise "Invalid Form Field: #{self.form}##{name} (#{klass}) Failure: #{result.failure.to_json}"
    end
    entities << entity
  end

  def klass_and_name_from(args)
    type, name = args
    if Forms::API::Entity::Registry.types[type]
      [Forms::API::Entity::Registry.types[type], name]
    else
      [Forms::API::Entity::Base, type]
    end
  end

  module ClassMethods
    def register(type)
      self.registered_type = type
      Forms::API::Entity::Registry.types[type] = self

      Forms::API::Entity::Registry.module_eval do
        define_method type do |*args, &block|
          opts = args.extract_options!
          name = args.first
          @position ||= 0
          entity type, name, opts.merge(position: @position), &block
          @position += 1
        end
      end
    end
  end
end

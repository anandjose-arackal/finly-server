class QuickView::Builders::Section < NonPersistentModel
  attr_accessor :key, :label, :entities

  validates :key, presence: true

  def initialize(config, &block)
    config.each_pair do |key, value|
      send("#{key}=", value)
    end
    self.label ||= self.key.to_s.humanize
    self.entities ||= []
    instance_eval(&block)
  end

  def entity(klass, config, &block)
    entity = klass.new(config, &block)
    unless entity.valid?
      raise "#{self.class.name}: #{entity.errors.full_messages}"
    end
    entities << entity
  end

  def render(context, exec_context, user, record, exposure, data)
    entities_data = []
    entities.each do |entity|
      entities_data << entity.render(context, exec_context, user, record, exposure, data)
    end
    {
        key: key,
        label: label,
        type: "section",
        data: entities_data
      }
  end

  module QuickView::Builders::Section::Registry
    extend ActiveSupport::Concern

    class_methods do

      def entity_type
        @entity_type
      end

      def register(entity_type)
        @entity_type = entity_type
        klass = self
        [QuickView::Builders::Entity, QuickView::Builders::Section].each do |k|
          k.define_method entity_type do |key, config, &block|
            entity(klass, config.merge(key: key), &block)
          end
        end
      end
    end

    def entity_type
      self.class.entity_type
    end

  end

end

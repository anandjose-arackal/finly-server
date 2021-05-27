module Masters::Entity::Record
  include ActiveSupport::Concern

  def clear_record_model_class
    @record_model_class = nil
  end

  # Responsible for generating anonymous model using the metadata provided in MasterSchema and MasterEntity
  #
  # @return [Class]
  def record_model_class
    return @record_model_class if @record_model_class.present?

    base_class = self.model.present? ? self.model : ApplicationRecord
    master_schema = self
    table_name = self.table_name
    @record_model_class = Class.new(base_class) do
      include SoftDeletable
      self.table_name = table_name

      # Avoiding memory leak with Anonymous ActiveRecords as per https://github.com/rails/rails/issues/31395
      # Anonymous Classes are added as descendants to the parent AR or Application record causing a memory leak
      # Clearing it from descendants of superclass as well as ApplicationRecord
      superclass.direct_descendants.delete(self)
      ApplicationRecord.descendants.delete(self)

      # set ancestry if nesting enabled
      if master_schema.has_nesting
        has_ancestry
      end

      unless master_schema.system_master
        default_scope { where(master_schema_id: master_schema.id) }
      end

      # For entities of lookup type, add a belongs_to association
      master_schema.entities.each do |entity|
        if entity.type?(:lookup)
          attr = entity.entity_key
          anonymous_class = entity.lookup_master_schema&.record_model_class
          if attr.end_with?('_id')
            attr = attr[0..(attr.length - 4)]
            belongs_to attr.to_sym, anonymous_class: anonymous_class
          else
            belongs_to "#{attr}_obj".to_sym, anonymous_class: anonymous_class, foreign_key: attr
          end
        end
        if entity.type?(:multi_lookup)
          has_many "#{entity.entity_key}_mappings".to_sym, -> { where master_entity_id: entity.id }, class_name: 'MasterMapping', foreign_key: 'from_record_id'
          anonymous_class = entity.lookup_master_schema&.record_model_class
          has_many entity.entity_key.to_sym, through: "#{entity.entity_key}_mappings".to_sym, source: 'to_record', anonymous_class: anonymous_class, source_type: entity.lookup_master_schema.model.name
        end
      end

      def self.name
        "MasterRecord"
      end

      define_method :to_exposure do
        master_schema.record_exposure_class.new(self)
      end

      define_method :as_json do |options = {}|
        if options[:compact]
          # Compact will only render the id and display name attributes
          {
              id: id,
              name: send(master_schema.primary_entity_key)
          }
        else
          Masters::JsonBuilder.(master_schema, self)
        end
      end
    end
  end

end
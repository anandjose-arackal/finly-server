module Masters::Entity::Record
  include ActiveSupport::Concern

  def clear_record_model_class
    @record_model_class = nil
  end

  def record_model_class
    return @record_model_class if @record_model_class.present?

    base_class = self.model.present? ? self.model : ApplicationRecord
    master_schema = self
    table_name = self.table_name
    @record_model_class = Class.new(base_class) do
      include SoftDeletable


      self.table_name = table_name

      # Avoiding memory leak with Anonymous ActiveRecords as per https://github.com/rails/rails/issues/31395
      # Clearing it from descendants of superclass as well as ApplicationRecord
      superclass.direct_descendants.delete(self)
      ApplicationRecord.descendants.delete(self)

      # For entities of lookup type, add a belongs_to association
      master_schema.entities.each do |entity|
        if entity.type?(:lookup)
          attr = entity.entity_key
          if attr.end_with?('_id')
            attr = attr[0..(attr.length - 4)]
            belongs_to attr.to_sym, -> { where company_id: entity.company_id }, anonymous_class: entity.lookup_master_schema.record_model_class
          end
        end
      end

      def self.name
        "Master#{table_name}"
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
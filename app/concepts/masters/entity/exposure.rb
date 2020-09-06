module Masters::Entity::Exposure
  include ActiveSupport::Concern

  # Creates a new Anonymous Exposure for the {Models::MasterSchema}
  #
  # @example
  #   MasterSchema.first.record_exposure_class
  #
  # @return [Class] Exposure Class for the {Models::MasterSchema}
  def record_exposure_class
    if @record_exposure_class.present?
      return @record_exposure_class
    end

    master_schema = self
    @record_exposure_class = Class.new(Exposures::API) do
      attribute :id, record_attribute: true

      master_schema.entities.each do |entity|
        if entity.type?(:lookup) or entity.type?(:parent_lookup)
          attribute entity.association_name, record_attribute: true, exposure: true, includes: [entity.association_name]
        else
          attribute entity.entity_key, record_attribute: true
        end
      end
    end
  end

end
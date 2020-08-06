class Masters::Schema::Records::Contract

  def self.build(master_schema)
    contract = Class.new(Reform::Form)

    # Setup Entities
    setup_entities(master_schema, contract)

    # Validate parent_associations
    # Todo

    # Validate lookup fields
    # Todo

    contract
  end

  def setup_entities(master_schema, contract)
    master_schema.entities.each do |entity|
      next unless entity.active

      args = {validates: {}}
      args[:validates][:presence] = true if entity.required
      args[:validates][:uniqueness] = true if entity.unique

      contract.property entity.entity_key, args
    end
  end

end
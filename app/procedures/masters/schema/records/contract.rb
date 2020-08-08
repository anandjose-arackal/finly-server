class Masters::Schema::Records::Contract

  def self.Build()
    Transactions::Task.build id: "find_master_schema" do |context, flow_options, circuit_options|
      master_schema = context[:master_schema]# || context[:model]
      context[:'contract.default.class'] = Masters::Schema::Records::Contract.with(master_schema)
      context[:'contract.default'] = context[:'contract.default.class'].new(context[:model])

      true
    end
  end

  def self.with(master_schema)
    contract = Class.new(Reform::Form) do
      define_method :as_json do |options={}|
        json = {id: self.id}
        master_schema.entities.each do |entity|
          json[entity.entity_key] = self.send(entity.entity_key)
        end
        json
      end
    end

    # Setup Entities
    setup_entities(master_schema, contract)

    # Validate parent_associations
    # Todo

    # Validate lookup fields
    # Todo

    contract
  end

  def self.setup_entities(master_schema, contract)
    master_schema.entities.each do |entity|
      next unless entity.active

      validates = {}
      validates[:presence] = true if entity.required
      validates[:uniqueness] = true if entity.unique
      args = {}
      args[:validates] = validates if validates.present?

      contract.send(:property, entity.entity_key, args)

      context = {
          entity: entity,
          contract: contract
      }
      entity.class.contract_evaluators.each do |name, evaluator|
        evaluator.call(context)
      end
    end
  end

end
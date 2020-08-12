class Masters::Schema::Records::Contract

  def self.Build()
    Transactions::Task.build id: "find_master_schema" do |context, flow_options, circuit_options|
      master_schema = context[:master_schema] # || context[:model]
      context[:'contract.default.class'] = Masters::Schema::Records::Contract.with(master_schema)
      context[:'contract.default'] = context[:'contract.default.class'].new(context[:model])

      true
    end
  end

  def self.with(master_schema)
    Class.new(Reform::Form) do
      master_schema.entities.each do |entity|
        next unless entity.active

        property entity.entity_key

        context = {
            entity: entity,
            contract: self
        }
        entity.class.contract_evaluators.each do |name, evaluator|
          instance_exec context, &evaluator
        end
      end
    end
  end

end
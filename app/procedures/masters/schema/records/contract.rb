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

      property :created_by, deserializer: -> (input, represented, **) {}
      property :company, deserializer: -> (input, represented, **) {}

      if master_schema.has_nesting
        property :ancestry, deserializer: -> (input, represented, *args) do
          represented.ancestry = input["parent_id"]
        end
      end

      master_schema.entities.only_active.each do |entity|
        next unless entity.active
        
        unless entity.type?(:multi_lookup)
          property entity.entity_key
        end

        if entity.type?(:multi_lookup)
          property entity.entity_key, virtual: true

          collection "#{entity.entity_key}_mappings".to_sym, populator: "#{entity.entity_key}_mappings!".to_sym do
            property :id
            property :company_id, deserializer: -> (input, represented, *args) do 
              represented.company_id = represented.contract_root.company.id
            end
            property :created_by_id, deserializer: -> (input, represented, *args) do
              represented.created_by_id = represented.contract_root.created_by.id
            end
            property :master_entity_id, deserializer: -> (input, represented, *args) do
              represented.master_entity_id = entity.id
            end
            property :_destroy, virtual: true
            property :to_record_id
            property :to_record_type, deserializer: -> (input, represented, *args) do
              represented.to_record_type = entity.lookup_master_schema.model.name
            end
            property :from_record_type, deserializer: -> (input, represented, *args) do
              represented.from_record_type = entity.master_schema.model.name
            end
          end

          define_method "#{entity.entity_key}_mappings!".to_sym do |collection:, fragment:, index:, options:, **|
            mappings = send("#{entity.entity_key}_mappings")
            mapping = mappings.find {|mapping| mapping.to_record_id.to_s == fragment["to_record_id"].to_s}

            if fragment["_destroy"]
              mappings.destroy(mapping)
              return skip!
            end

            mapping || mappings.append(MasterMapping.new)
          end
        end

        context = {
            entity: entity,
            contract: self
        }
        entity.class.contract_evaluators.each do |name, evaluator|
          instance_exec context, &evaluator
        end
      end
      
      # Fetch extracts the data from the form using entity or entity_key
      def fetch(entity: nil, entity_key: nil, raw_values: false, user: nil)
        entity_key = entity.entity_key if entity.present?
        return nil unless entity_key.present?

        value = to_form.dig(entity_key)
        if !raw_values and entity.present? and value.present?
          if entity.choices_scope.present?
            user ||= RequestStoreUtil.current_user
            choice = entity.choices_scope.find_by_id(value, params: {}, user: user)
            if choice.present?
              value = choice[:name]
            else
              value = nil
            end
          end
        end
        value
      end
    end
  end

end
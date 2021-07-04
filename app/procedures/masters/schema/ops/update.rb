class Masters::Schema::Ops::Update < Masters::Schema::Ops::Base

  # Todo : Updating the schema
  step FindMasterSchema()
  step Policy::Pundit(Masters::Schema::Policy, :update?)
  step Contract::Build(constant: Masters::Schema::Contract)
  step :set_entity_keys!
  step Contract::Validate()
  step Contract::Persist()
  # step Masters::Schema::Ops::MigrationRunner::Build()
  step Transactions::Messages::SuccessMessage('Master Schema Updated')

  def set_entity_keys!(context, model:, params:, ** )
    all_fields = {}
    if params[:system_master].present? || model.system_master
      MasterEntity::SYSTEM_MASTER_CUSTOM_FIELDS.each do |key|
        all_fields[key] = true
      end
    else
      MasterEntity::CUSTOM_MASTER_CUSTOM_FIELDS.each do |key|
        all_fields[key] = true
      end
    end

    if params[:entities].present?
      params[:entities].each do |entity|
        if entity[:entity_key].present? && entity[:active].present?
          all_fields[entity[:entity_key]] = false
        end
      end

      available_fields = []

      all_fields.keys.each do |key|
        available_fields << key if all_fields[key]
      end

      index = 0
      params[:entities].each do |entity|
        if !entity[:entity_key].present? and !entity[:active].present?
          if index >= available_fields.length
            return on_error context, :entities, "Exceeds the maximum number of custom fields (#{model.system_master ? 5 : 10 })"
          end
          entity[:entity_key] = available_fields[index]
          index += 1
        end
      end
    end

    true
  end


end
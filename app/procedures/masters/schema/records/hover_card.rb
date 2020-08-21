class Masters::Schema::Records::HoverCard < HoverCard::API

  model -> (context) {
    params = context[:params]
    current_user = context[:current_user]
    # master_key can be fetched from the route with the format masters.<master_key>
    master_key = params[:route].split(".")[1]

    context[:master_schema] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
    unless context[:master_schema].present?
      return on_error context, :base, 'master not found'
    end
    context[:model] = context[:master_schema].record_model_class
    unless context[:model].present?
      return on_error context, :base, 'master not found'
    end

    context[:model]
  }
  policy Masters::Schema::Records::Policy
  policy_action :hover_card?
  json do |context, record|
    json = {}
    context[:master_schema].entities.each do |entity|
      if entity.type?(:lookup) or entity.type?(:parent_lookup)
        json[entity.label] = record.send(entity.association_name)&.as_json(compact: true)&.dig(:name)
      else
        json[entity.label] = record.send(entity.entity_key)
      end
    end
    json
  end

end
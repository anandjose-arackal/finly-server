# This generates data cards for all simple masters
class DataCards::Adapters::Masters < DataCards::API

  def init(context, args)
    super(context, args)
    context[:route] = route = args&.dig(:params, :route)
    return on_error(context, :base, "Invalid route") unless route.start_with?("masters.")

    # Load master
    master_route = route.gsub("masters.", "")
    master_klass = Masters::Router[master_route]&.first&.klass
    return on_error(context, :base, "Invalid document") unless master_klass.present?

    context[:master] = master = MasterSchema.find_by(klass_name: master_klass.to_s)
    return on_error(context, :base, "Invalid document") unless master.present?

    # Load all master entities
    context[:master_entities] = master.entities

    # Find the document
    context[:model] = model =  master.model.find_by(id: context[:params][:id])
    return on_error(context, :base, "Record not found") unless model.present?

    # Todo Authorize the access
    # return unauthorized!(context) unless master.authorized?(model, args[:current_user])

    # Build contract
    context['contract.default'] = contract = master.contract.new(model)
  
    return on_error(context, :base, "Contract not found") if contract.blank?

    true
  end

  def build(context, master:, builder:, **)
    builder.title = build_title(context)
    builder.subtitle = build_subtitle(context)
    builder.type = context[:model].class.name
    builder.details = build_body(context)
    true
  end

  private

  # We build the title by fetching the value of the entity which has the primary_key as true
  # In case no entities have primary_key set as true, then we set the first entity as the title entity
  def build_title(context)
    title_entity = context[:master_entities].select {|entity| entity.primary_key }&.first
    if title_entity.blank?
      title_entity = context[:master_entities].first
    end
    return nil if title_entity.blank?

    context['contract.default'].fetch(entity: title_entity, user: context[:current_user])
  end

  # We build subtitle value using the Sequence Entity. In case a master does not have any sequence entity,
  # then we do not set subtitle.
  def build_subtitle(context)
    subtitle_entity = context[:master_entities].select {|entity| entity.type == "MasterEntity::Sequence" }&.first
    return nil if subtitle_entity.blank?

    context['contract.default'].fetch(entity: subtitle_entity, user: context[:current_user])
  end

  # We build the body with all the fields available in the master
  def build_body(context)
    entities = context[:master_entities] # TODO skip if flag do not show in cards is set
    result = []
    entities.each do |entity|
      value = context['contract.default'].fetch(entity: entity, user: context[:current_user])
      label = entity.label
      result << {label: label, value: value}
    end
    result
  end

end
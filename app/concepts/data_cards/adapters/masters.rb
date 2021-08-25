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
    # builder.icon = defaults[:header][:icon] # TODO
    builder.title = retrieve(context, "title")&.first&.dig(:value)
    builder.subtitle = retrieve(context, "subtitle")&.first&.dig(:value)
    builder.type = context[:model].class.name
    builder.details = retrieve(context, "body")

    true
  end

  private

  def retrieve(context, key)
    entities = context[:master_entities].select {|entity| entity.data_card_config&.dig('type') == key}
    result = []
    entities.each do |entity|
      value = context['contract.default'].fetch(entity: entity, user: context[:current_user])
      label = entity.label
      icon = nil
      # icon = entity.data_card_config[:icon] # TODO Default icon in case the icon isn't configured
      result << {value: value, label: label, icon: icon}
    end
    result
  end

end
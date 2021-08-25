# Params
# {route: "forms/YesBankVendors", id: "120"}
class DataCards::Adapters::Forms < DataCards::API

  def init(context, args)
    super(context, args)
    context[:route] = route = args&.dig(:params, :route)
    return on_error(context, :base, "Invalid route") unless route.start_with?("forms.")

    # Load form
    form_route = route.gsub("forms.", "")
    form_klass = Forms::Router[form_route]&.first&.klass
    return on_error(context, :base, "Invalid document") unless form_klass.present?

    context[:form] = form = Form.find_by(klass_name: form_klass.to_s)
    return on_error(context, :base, "Invalid document") unless form.present?

    # Load all form entities
    context[:form_entities] = form.entities.reject { |entity| entity.is_in_collection?(form: form) }

    # Find the document
    context[:model] = model =  form.model.find_by(id: context[:params][:id])
    return on_error(context, :base, "Record not found") unless model.present?

    # Authorize the access
    return unauthorized!(context) unless form.authorized?(model, args[:current_user])

    # Build contract
    context['contract.default'] = contract = form.contract(args[:current_user]).new(model)
  
    return on_error(context, :base, "Contract not found") if contract.blank?

    true
  end

  def build(context, form:, builder:, **)
    # builder.icon = defaults[:header][:icon] # TODO
    builder.title = retrieve(context, "title")&.first&.dig(:value)
    builder.subtitle = retrieve(context, "subtitle")&.first&.dig(:value)
    builder.type = context[:model].class.name
    builder.status = retrieve(context, "status")&.first&.dig(:value)&.humanize
    builder.details = retrieve(context, "body")

    true
  end

  private

  def retrieve(context, key)
    entities = context[:form_entities].select {|entity| entity.data_card_config&.dig('type') == key}
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

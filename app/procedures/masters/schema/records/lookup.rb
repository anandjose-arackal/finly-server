class Masters::Schema::Records::Lookup < Lookup::API

  step :init_record_model_class, before: :define_search
  step Resolver::Transactions::Load(klass: Masters::Schema::Records::LookupResolver, paginate: true), replace: "transactions.resolver.model"

  def init_record_model_class(context, params:, current_user:, **)
    # master_key can be fetched from the route with the format masters.<master_key>
    master_key = params[:route].split(".")[1]

    context[:model] = params[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
    unless context[:model].present?
      return on_error context, :base, 'master not found'
    end
    context[:model_class] = params[:model_class] = context[:model].record_model_class
    unless params[:model_class].present?
      return on_error context, :base, 'master not found'
    end

    true
  end

  # Todo dynamic search_key
  def search_key(context)
    "#{context['model'].primary_entity_key}_cont"
  end

  # Todo
  def attributes(context)
    return @attributes if @attributes.present?

    @attributes = {}
    @attributes[:id] = Lookup::Attribute.new(id: :id, visible: false, primary: true)
    context[:model].entities.only_active.entities_for_lookup.each do |entity|
      @attributes[entity.entity_key] = Lookup::Attribute.new(id: entity.entity_key, label: entity.label)
    end
    @attributes
  end

  def render_record(context, record:, model:, **)
    json = {id: record.id}
    model.entities.only_active.entities_for_lookup.each do |entity|
      json[entity.entity_key] = record.send(entity.entity_key)
    end
    json
  end

end
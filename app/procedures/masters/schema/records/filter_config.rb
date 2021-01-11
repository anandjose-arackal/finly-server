class Masters::Schema::Records::FilterConfig < Filters::API
  # step :init_record_model_class, before: :build_config
  # step :build_attributes, before: :build_config

  def init_record_model_class(context)
    # master_key can be fetched from the route with the format masters.<master_key>
    params = context[:params]
    current_user = context[:current_user]
    master_key = params[:route].split(".")[1]

    context[:model] = MasterSchema.find_by(company_id: current_user.company_id, master_key: master_key)
    unless context[:model].present?
      return on_error context, :base, 'master not found'
    end
    context[:model_class] = params[:model_class] = context[:model].record_model_class
    unless params[:model_class].present?
      return on_error context, :base, 'master not found'
    end

    true
  end


  def attributes(context)
    init_record_model_class(context)

    attributes_list = {}.with_indifferent_access
    context[:model].entities.each do |entity|
      choices = nil
      if entity.filter_type == :lookup
        choices = entity.choices_scope
      end
      attributes_list[entity.entity_key.to_sym] = Filters::API::Attribute.new(
        {
          field_key: entity.entity_key.to_sym,
          label: entity.label,
          field_type: entity.filter_type,
          hint: entity.hint,
          choices: choices,
          simple: false
        }
      )
    end
    attributes_list
  end


end
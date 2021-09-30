class Forms::Ops::Widgets < Transactions::API
  step :find_model
  step :find_document
  step :generate_data

  # key to path mapper
  WIDGET_PARAM_MAPPER = {
    about_document: {
      submitted_at:     "submitted_at",
      approved_at:      "approved_at",
      controlling_user: "controlling_user"
    }
  }.freeze

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:model])&.name, company_id: current_user.company_id)
    return on_error context, :base, 'Form not found' unless context[:model].present?
    true
  end

  def find_document(context, params:, current_user:, **)
    klass = params[:model].classify.constantize
    context[:document] = klass.present? && klass.find_by(id: params[:document_id]) if params[:document_id].present?
    return on_error context, :base, 'Document not found' unless context[:document].present?
    true
  end

  def generate_data(context, params:, current_user:, **)
    params_list = WIDGET_PARAM_MAPPER[params[:widget].to_sym]
    document = context[:document]

    data = {}
    params_list.each do |key, path|
      split_attributes = path.split('.')
      if split_attributes.size > 1
        value = document
        split_attributes.each do |next_value|
          value = value.send(next_value)
        end
        data[key] = value
      else
        data[key] = document.send(path)
      end
    end
    context[:widget_data] = {params[:widget].to_sym => data}

    true
  end
end
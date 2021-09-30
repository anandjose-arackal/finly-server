class Forms::Ops::Widgets < Transactions::API
  step :find_document
  step :generate_data

  # key to path mapper
  WIDGET_PARAM_MAPPER = {
    about_document: {
      submitted_at:     "submitted_at",
      approved_at:      "approved_at",
      controlling_user: "controlling_user.name"
    }
  }.freeze

  def find_document(context, params:, current_user:, **)
    klass = params[:model].singularize.downcase == 'vendor' ? YesBankVendor : params[:model].classify.constantize rescue nil
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
          value = value.try(next_value)
          break if value.nil?
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
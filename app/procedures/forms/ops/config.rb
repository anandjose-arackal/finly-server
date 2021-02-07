class Forms::Ops::Config < Transactions::API

  # schema do
  #   params do
  #     required(:route).value(included_in?: Forms::Router.map.keys)
  #   end
  # end

  step :validate_route
  pass :find_model
  step :validate_model
  step :retrieve_user
  step Policy::Pundit(Forms::Policy, :config?)

  def validate_route(options, params:, **)
    unless Forms::Router.map.keys.include?(params[:route])
      add_message(options, :error, :invoice, "Invalid Route")
      return
    end
    true
  end

  def find_model(context, params:, current_user:, **)
    context[:model] = Form.where.not(klass_name: nil).find_by(klass_name: Forms::Router.klass(params[:route])&.name, company_id: current_user.company_id)
  end

  def validate_model(context, model:, **)
    return on_error context, :base, 'Form not found' unless model.present?

    true
  end

  def retrieve_user(options, params:, current_user:, **)
    klass = document = nil
    case params[:document_type]
    when "YesBankVendor"
      klass = YesBankVendor
    when "Invoice"
      klass = Invoice
    else
      # no nothing
    end

    document = klass.present? && klass.find_by(id: params[:document_id]) if params[:document_id].present?

    if document.present? && document.created_by.present?
      options[:created_by] = document.created_by
    else
      options[:created_by] = current_user
    end

    true
  end
end
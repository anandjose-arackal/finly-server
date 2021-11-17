class Forms::Import::Template < Transactions::API
  step :init_form
  step :process_template

  def init_form(context, params:, current_user:, **)
    form_key = params[:route].split(".")[1]
    context[:form] = Form.where(company_id: current_user.company.id, klass_name: Forms::Router.klass(form_key)&.name).first
  end

  def process_template(context, params:, current_user:, form:, **)
    context[:form_import] = Forms::Import::Processor.(form, current_user)
    context[:template_url] = context[:form_import].build_import_template
  end

end
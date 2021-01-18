class Masters::ExportTemplates::Ops::Default < Transactions::API
  step Policy::Pundit(Masters::ExportTemplates::Policy, :default?)

  step :default!

  def default!(options, current_user:, params:, **)
    options['result'] = ExportManager::TemplateMaster.get_default_template(params[:resource])
  end
end

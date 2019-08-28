class ExportTemplates::Create < Transaction

  step Model(ExportTemplate, :new)
  step :assign_current_user!
  step Policy::Pundit(ExportTemplates::Policy, :create?)
  step Contract::Build(constant: ExportTemplates::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step :success

  def success(options)
    add_message options, :success, :base, 'Template created successfully'
    true
  end

  def assign_current_user!(options)
    options["model"].created_by_user = options['current_user']
    options["model"].company = options["model"].created_by_user&.company
    true
  end

end

class ExportTemplates::Create < Transaction

  step Model(ExportTemplate, :new)
  step Transaction::AssignModelUser(key: :created_by_user)
  step Policy::Pundit(ExportTemplates::Policy, :create?)
  step Contract::Build(constant: ExportTemplates::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transaction::SuccessMessage('Template created successfully')

end

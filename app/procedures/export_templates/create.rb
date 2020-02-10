class ExportTemplates::Create < Transactions::API

  step Model(ExportTemplate, :new)
  step Transactions::API::AssignModelUser(key: :created_by_user)
  step Policy::Pundit(ExportTemplates::Policy, :create?)
  step Contract::Build(constant: ExportTemplates::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step Transactions::Messages::SuccessMessage('Template created successfully')

end

class Masters::ExportTemplates::Ops::Create < Transactions::API
  step Model(ExportTemplateNew, :new)
  step Transactions::API::AssignModelUser(key: :created_by)
  step Policy::Pundit(Masters::ExportTemplates::Policy, :create?)
  step Contract::Build(constant: Masters::ExportTemplates::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step :set_modified!
  step Messages::Task::SuccessMessage('Template saved')

  def set_modified!(options, model:, **)
    model.update(modified: true)
    true
  end
end

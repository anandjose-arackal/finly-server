class Masters::ExportTemplates::Ops::Update < Transactions::API
  step Model(ExportTemplateNew, :find_by)
  step Policy::Pundit(Masters::ExportTemplates::Policy, :update?)
  step Contract::Build(constant: Masters::ExportTemplates::Contract)
  step Contract::Validate()
  step Contract::Persist()
  step :set_modified!
  step Messages::Task::SuccessMessage('Template updated successfully')

  def set_modified!(options, model:, **)
    model.update(modified: true)
    true
  end
end

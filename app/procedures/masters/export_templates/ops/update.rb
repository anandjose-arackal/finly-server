class Masters::ExportTemplates::Ops::Update < Transactions::API
  step Model(ExportTemplateNew, :find_by)
  step Policy::Pundit(Masters::ExportTemplates::Policy, :update?)
  step Contract::Build(constant: Masters::ExportTemplates::Contract)
  step Contract::Validate()
  step :remove_old_role_mappings!
  step Contract::Persist()
  step :set_modified!
  step Messages::Task::SuccessMessage('Template updated successfully')

  def remove_old_role_mappings!(options, model:, **)
    model.role_mappings.destroy_all
    true
  end

  def set_modified!(options, model:, **)
    model.update(modified: true)
    true
  end
end

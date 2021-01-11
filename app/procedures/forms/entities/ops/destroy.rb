class Forms::Entities::Ops::Destroy < Transactions::API

  step Model(FormEntity, :find_by_uuid)

  step Policy::Pundit(Forms::Entities::Policy, :destroy?)

  step :destroy_dependencies

  step :destroy!

  step Transactions::Messages::SuccessMessage('Successfully Deleted Field')

  def destroy_dependencies(options, model:, **)
    if model.entity_type == 'dropdown' || model.entity_type == 'lookup'
      model_id = model.id
      FormChoiceDependency.where("form_choice_dependencies.dependent_entity_id = ? OR
                                  form_choice_dependencies.controlling_entity_id = ?", model_id,  model_id).destroy_all
    end
    true
  end

  def destroy!(options, model:, **)
    model.destroy
  end
end
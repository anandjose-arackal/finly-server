class EventManager::Workflows::Contract < Transactions::Contract
  include EventManager::Actions::FileManager::Validations

  property :name, validates: {presence: true}
  property :description, validates: {presence: true}
  property :model_class, validates: {presence: true, inclusion: {in: Documents::Master.list}}
  property :personal, default: false
  property :user_id, validates: {presence: true}
  property :company_id, validates: {presence: true}
  collection :file_manager_actions, populate_if_empty: EventFileManagerAction do
    property :export_template_id, validates: {presence: true}
  end

  validate :atleast_one_action

  def atleast_one_action
    if file_manager_actions.blank?
      errors.add :action, 'is not defined'
      return
    end
  end

end
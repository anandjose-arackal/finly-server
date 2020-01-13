class ActionsManager::Master::CreditNotes::Index < ActionsManager::Master::Base

  register_handle :credit_notes_index
  register_actions [:create]

  def create
    user.has_policy_role?(UserRole.id_for(:credit_note_initiator))
  end
end
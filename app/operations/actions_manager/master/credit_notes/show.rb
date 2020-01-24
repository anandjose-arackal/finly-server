class ActionsManager::Master::CreditNotes::Show < ActionsManager::Master::Base

  attr_accessor :credit_note

  register_handle :credit_note_show
  register_actions [:update_and_submit, :edit, :policy_editable, :retract, :approve, :reject, :take_control, :return_control,
                    :void, :destroy, :tds_editable]

  def initialize(user = nil, params = {})
    super
    op_show = Docs::P2P::CreditNotes::Ops::Show.(params: params, "current_user" => user)

    if op_show.success?
      self.credit_note = op_show['model']
    else
      add_message :error, "Credit Note not found"
      return
    end
  end

  def update_and_submit
    CreditNoteStatus.ids_for(:draft, :rejected, :retracted).include?(credit_note.status_id) && credit_note.user_id == user.id
  end

  def edit
    (CreditNote.open_statuses.include?(credit_note.status_id) && credit_note.user_id == user.id) || (credit_note.awaiting_approval? && credit_note.get_reviewers.include?(user))
  end

  def policy_editable
    CreditNote.open_statuses.include?(credit_note.status_id) && credit_note.user_id == user.id
  end

  def retract
    credit_note.awaiting_approval? && credit_note.user_id == user.id
  end

  def approve
    credit_note.awaiting_approval? && credit_note.get_reviewers.include?(user)
  end

  def reject
    approve
  end

  def take_control
    credit_note.awaiting_approval? && credit_note.get_reviewers.exclude?(user) && user.vendor_payment_admin?
  end

  def return_control
    credit_note.awaiting_approval? && credit_note.get_reviewers.include?(user) && user.vendor_payment_admin? && has_taken_control?
  end

  def void
    (credit_note.approved? || credit_note.auto_approved?) && user.vendor_payment_admin?
  end

  def destroy
    (CreditNote.open_statuses.include?(credit_note.status_id) && credit_note.user_id == user.id)
  end

  def tds_editable
    false
  end

  private

  def has_taken_control?
    credit_note.dlrms.where(level_id: credit_note.controlling_level_id).map(&:taken_control_by_id).include?(user.id)
  end


end
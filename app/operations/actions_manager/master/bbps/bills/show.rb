class ActionsManager::Master::Bbps::Bills::Show < ActionsManager::Master::Base

  attr_accessor :bbps_bill

  register_handle :bbps_bills_show
  register_actions [:update_and_submit, :edit, :policy_editable, :retract, :approve, :reject, :take_control,
                    :return_control, :destroy, :view_payment_ticket, :raise_dispute,
                    :bill_validate, :download_receipt, :transaction_status]

  def initialize(user = nil, params = {})
    super
    op_show = Docs::UtilityBills::Bills::Ops::Show.(params: params, "current_user" => user)

    if op_show.success?
      self.bbps_bill = op_show['model']
    else
      add_message :error, "Utility Bill Record not found"
      return
    end
  end

  def update_and_submit
    # !bbps_bill.bill_validation_required? && (bbps_bill.open? || bbps_bill.retracted? || bbps_bill.rejected?) && bbps_bill.subscription.pocs.include?(user) && bbps_bill.autofetched
    !bbps_bill.bill_validation_required? && (bbps_bill.open? || bbps_bill.retracted? || bbps_bill.rejected?) && bbps_bill.subscription.pocs.include?(user)
  end

  # def submit
  #   !bbps_bill.bill_validation_required? && (bbps_bill.open? || bbps_bill.retracted? || bbps_bill.rejected?) && bbps_bill.subscription.pocs.include?(user) && !bbps_bill.autofetched
  # end

  def edit
    (BbpsBill.open_statuses.include?(bbps_bill.status_id) && bbps_bill.subscription.pocs.include?(user)) || (bbps_bill.awaiting_approval? && bbps_bill.get_reviewers.include?(user))
  end

  def policy_editable
    BbpsBill.open_statuses.include?(bbps_bill.status_id) && bbps_bill.subscription.pocs.include?(user)
  end

  def retract
    bbps_bill.awaiting_approval? && bbps_bill.user_id == user.id
  end

  def approve
    !bbps_bill.bill_validation_required? && bbps_bill.awaiting_approval? && bbps_bill.get_reviewers.include?(user)
  end

  def reject
    approve
  end

  def take_control
    bbps_bill.awaiting_approval? && bbps_bill.get_reviewers.exclude?(user) && user.vendor_payment_admin?
  end

  def return_control
    bbps_bill.awaiting_approval? && bbps_bill.get_reviewers.include?(user) && user.vendor_payment_admin? && has_taken_control?
  end

  def view_payment_ticket
    BbpsBill.status_ids(:paid, :failed, :payment_ticket_created, :payment_initiated).include?(bbps_bill.status_id)
  end

  # def deactivate
  #   (bbps_bill.approved? || bbps_bill.auto_approved?) && user.vendor_payment_admin?
  # end

  # def reactivate
  #   # bbps_bill.deactivated? && user.vendor_payment_admin?
  # end

  def destroy
    !bbps_bill.autofetched && (BbpsBill.open_statuses.include?(bbps_bill.status_id) && (bbps_bill.subscription.pocs.include?(user) || user.vendor_payment_admin?))
  end

  def raise_dispute
    BbpsBill.status_ids(:failed, :paid).include?(bbps_bill.status_id)
  end

  private

  def has_taken_control?
    bbps_bill.dlrms.where(level_id: bbps_bill.controlling_level_id).map(&:taken_control_by_id).include?(user.id)
  end

  def bill_validate
    bbps_bill.bill_validation_required? && (bbps_bill.subscription.user_id == user.id || bbps_bill.subscription.pocs.include?(user) || bbps_bill.get_reviewers.include?(user))
  end

  def download_receipt
    BbpsBill.status_ids(:failed, :paid).include?(bbps_bill.status_id)
  end

  def transaction_status
    BbpsBill.status_ids(:payment_initiated, :paid, :failed).include?(bbps_bill.status_id)
  end
end
class Docs::UtilityBills::Bills::Policy < ApplicationPolicy

  def submit?
    user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) && record.subscription.pocs.include?(user) && (record.open? || record.retracted? || record.rejected?)
  end

  def approve?
    record.awaiting_approval? && record.get_reviewers.include?(user)
  end

  def update?
    ((record.open? || record.retracted? || record.rejected?) && record.subscription.pocs.include?(user) && user.has_policy_role?(UserRole.id_for(:utility_bill_initiator))) || (record.awaiting_approval? && record.get_reviewers.include?(user))
  end

  def index?
    user.vendor_payment_admin? ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
  end

  def show?
    (record.company_id == user.company_id) &&
        (
        user.vendor_payment_admin? ||
            record.user_id == user.id ||
            reviewing_user? ||
            record.subscription.pocs.include?(user) ||
            user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
            user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
            user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
            user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
            user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
            user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) ||
            user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor))
        )
  end

  def reject?
    record.awaiting_approval? && record.get_reviewers.include?(user)
  end

  def retract?
    record.awaiting_approval? && record.user_id == user.id
  end

  def destroy?
    !record.autofetched && (user.vendor_payment_admin? || (user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) && record.subscription.pocs.include?(user) && (record.open? || record.retracted? || record.rejected?)))
  end

  def take_control?
    user.vendor_payment_admin? && record.awaiting_approval? && record.get_reviewers.exclude?(user)
  end

  def return_control?
    user.vendor_payment_admin? && record.awaiting_approval? && record.taken_control? && record.get_reviewers.include?(user)
  end

  def export?
    true
  end

  # def return_control?
  #
  # end

  private

  def reviewing_user?
    reviewing_user_ids = record.dlrms.pluck(:reviewer_id) + record.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(user.id)
  end

  def poc?
    record.subscription_pocs.pluck(:user_id).include?(user.id)
  end

end
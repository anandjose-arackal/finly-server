class Docs::UtilityBills::Subscriptions::Policy < ApplicationPolicy

  def create?
    user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator))
  end

  def approve?
    record.awaiting_approval? && record.get_reviewers.include?(user)
  end

  def update?
    # Owner of Document When in Open State
    # Controlling User When in awaiting_approval state
    # Admin Post Approval
    (BbpsBillerSubscription.open_statuses.include?(record.status_id) && record.user_id == user.id) ||
        (record.awaiting_approval? && record.get_reviewers.include?(user)) ||
        (BbpsBillerSubscriptionStatus.ids_for(:approved, :auto_approved, :deactivated, :reactivated).include?(record.status_id) && user.vendor_payment_admin?)
  end

  def index?
    user.vendor_payment_admin? ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor))
  end

  def show?
    (record.company_id == user.company_id) &&
        user.vendor_payment_admin? ||
        record.user_id == user.id ||
        reviewing_user? ||
        poc? ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
  end

  def reject?
    record.get_reviewers.include?(user)
  end

  def submit?
    BbpsBillerSubscription.open_statuses.include?(record.status_id) && record.user_id == user.id
  end

  def retract?
    record.awaiting_approval? && record.user_id == user.id
  end

  def destroy?
    BbpsBillerSubscription.open_statuses.include?(record.status_id) && record.user_id == user.id
  end

  def take_control?
    user.vendor_payment_admin? && record.awaiting_approval? && record.get_reviewers.exclude?(user)
  end

  def return_control?
    user.vendor_payment_admin? && record.awaiting_approval? && record.taken_control? && record.get_reviewers.include?(user)
  end

  def deactivate?
    user.vendor_payment_admin? && (record.approved? || record.auto_approved? || record.reactivated?)
  end

  def reactivate?
    user.vendor_payment_admin? && (record.deactivated?)
  end

  def add_bill?
    (record.pocs.include?(user) || user.vendor_payment_admin?) && (BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated).include?(record.status_id))
  end

  private

  def reviewing_user?
    reviewing_user_ids = record.dlrms.pluck(:reviewer_id) + record.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(user.id)
  end

  def poc?
    record.pocs.include?(user)
  end

end
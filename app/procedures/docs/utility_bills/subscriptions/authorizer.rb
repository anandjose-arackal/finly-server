class Docs::UtilityBills::Subscriptions::Authorizer

  attr_reader :user, :model

  def initialize(user, model)
    @user, @model = user, model
  end

  def create?
    @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator))
  end

  def approve?
    @model.awaiting_approval? && @model.get_reviewers.include?(@user)
  end

  def update?
    # Owner of Document When in Open State
    # Controlling User When in awaiting_approval state
    # Admin Post Approval
    (BbpsBillerSubscription.open_statuses.include?(@model.status_id) && @model.user_id == @user.id) ||
        (@model.awaiting_approval? && @model.get_reviewers.include?(@user)) ||
        (BbpsBillerSubscriptionStatus.ids_for(:approved, :auto_approved, :deactivated, :reactivated).include?(@model.status_id) && @user.vendor_payment_admin?)
  end

  def index?
    @user.vendor_payment_admin? ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor))
  end

  def show?
    (@model.company_id == @user.company_id) &&
        @user.vendor_payment_admin? ||
        @model.user_id == @user.id ||
        reviewing_user? ||
        poc? ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
  end

  def reject?
    @model.get_reviewers.include?(@user)
  end

  def submit?
    BbpsBillerSubscription.open_statuses.include?(@model.status_id) && @model.user_id == @user.id
  end

  def retract?
    @model.awaiting_approval? && @model.user_id == @user.id
  end

  def destroy?
    BbpsBillerSubscription.open_statuses.include?(@model.status_id) && @model.user_id == @user.id
  end

  def take_control?
    @user.vendor_payment_admin? && @model.awaiting_approval? && @model.get_reviewers.exclude?(@user)
  end

  def return_control?
    @user.vendor_payment_admin? && @model.awaiting_approval? && @model.taken_control? && @model.get_reviewers.include?(@user)
  end

  def deactivate?
    @user.vendor_payment_admin? && (@model.approved? || @model.auto_approved? || @model.reactivated?)
  end

  def reactivate?
    @user.vendor_payment_admin? && (@model.deactivated?)
  end

  def add_bill?
    (@model.pocs.include?(@user) || @user.vendor_payment_admin?) && (BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated).include?(@model.status_id))
  end

  private

  def reviewing_user?
    reviewing_user_ids = @model.dlrms.pluck(:reviewer_id) + @model.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(@user.id)
  end

  def poc?
    @model.pocs.include?(@user)
  end
end

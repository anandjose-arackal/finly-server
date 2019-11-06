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

  def blah?
  end

  def update?
    ((@model.draft? || @model.retracted? || @model.rejected?) && @model.user_id == @user.id) || (@model.awaiting_approval? && @model.get_reviewers.include?(@user))
  end

  def index?
    @user.vendor_payment_admin? || @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) || @user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer))
  end

  def show?
    @user.vendor_payment_admin? || @model.user_id == @user.id || reviewing_user || poc?
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

  def take_control?
    @user.vendor_payment_admin? && @model.get_reviewers.exclude?(@user)
  end

  def deactivate?
    @user.vendor_payment_admin? && (@model.approved? || @model.auto_approved?)
  end

  def reactivate?
    @user.vendor_payment_admin? && (@model.deactivated?)
  end

  private

  def reviewing_user?
    reviewing_user_ids = @model.dlrms.pluck(:reviewer_id) + @model.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(@user.id)
  end

  def poc?
    @model.subscription_pocs.pluck(:user_id).include?(@user.id)
  end

end

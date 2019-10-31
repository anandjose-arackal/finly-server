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
    ((@model.draft? || @model.retracted? || @model.rejected?) && @model.user_id == @user.id) || (@model.awaiting_approval? && @model.get_reviewers.include?(@user))
  end

  def index?
    @user.vendor_payment_admin? || @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) || @user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer))
  end

  private
end

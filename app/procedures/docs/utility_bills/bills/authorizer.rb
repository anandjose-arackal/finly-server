class Docs::UtilityBills::Bills::Authorizer

  attr_reader :user, :model

  def initialize(user, model)
    @user, @model = user, model
  end

  def submit?
    @user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) && @model.subscription.pocs.include?(@user) && (@model.open? || @model.retracted? || @model.rejected?)
  end

  def approve?
    @model.awaiting_approval? && @model.get_reviewers.include?(@user)
  end

  def update?
    ((@model.open? || @model.retracted? || @model.rejected?) && @model.subscription.pocs.include?(@user) && @user.has_policy_role?(UserRole.id_for(:utility_bill_initiator))) || (@model.awaiting_approval? && @model.get_reviewers.include?(@user))
  end

  def index?
    @user.vendor_payment_admin? ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor)) ||
        @user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor))
  end

  def show?
    (@model.company_id == @user.company_id) &&
        (
        @user.vendor_payment_admin? ||
            @model.user_id == @user.id ||
            reviewing_user? ||
            @model.subscription.pocs.include?(@user) ||
            @user.has_policy_role?(UserRole.id_for(:utility_bill_reviewer)) ||
            @user.has_policy_role?(UserRole.id_for(:utility_bill_master_initiator)) ||
            @user.has_policy_role?(UserRole.id_for(:utility_bill_master_reviewer)) ||
            @user.has_policy_role?(UserRole.id_for(:bank_payment_request_initiator)) ||
            @user.has_policy_role?(UserRole.id_for(:bank_payment_request_reviewer)) ||
            @user.has_policy_role?(UserRole.id_for(:bank_payment_request_creditor)) ||
            @user.has_policy_role?(UserRole.id_for(:bank_payment_request_auditor))
        )
  end

  def reject?
    @model.awaiting_approval? && @model.get_reviewers.include?(@user)
  end

  def retract?
    @model.awaiting_approval? && @model.user_id == @user.id
  end

  def destroy?
    !@model.autofetched && (@user.vendor_payment_admin? || (@user.has_policy_role?(UserRole.id_for(:utility_bill_initiator)) && @model.subscription.pocs.include?(@user) && (@model.open? || @model.retracted? || @model.rejected?)))
  end

  def take_control?
    @user.vendor_payment_admin? && @model.get_reviewers.exclude?(@user)
  end

  def return_control?
    @user.vendor_payment_admin? && @model.get_reviewers.include?(@user)
  end

  # def return_control?
  #
  # end

  private

  def reviewing_user?
    reviewing_user_ids = @model.dlrms.pluck(:reviewer_id) + @model.dlrms.pluck(:forwarded_to_id)
    reviewing_user_ids.include?(@user.id)
  end

  def poc?
    @model.subscription_pocs.pluck(:user_id).include?(@user.id)
  end

end

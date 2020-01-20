class ActionsManager::Master::Bbps::Subscriptions::Show < ActionsManager::Master::Base

  attr_accessor :bbps_subscription

  register_handle :bbps_subscriptions_show
  register_actions [:update_and_submit, :edit, :policy_editable, :retract, :approve, :reject, :take_control, :return_control,
                    :deactivate, :reactivate, :add_bill, :raise_dispute, :destroy, :fetch_bill]

  def initialize(user = nil, params = {})
    super
    op_show = Docs::UtilityBills::Subscriptions::Ops::Show.(params: params, "current_user" => user)

    if op_show.success?
      self.bbps_subscription = op_show['model']
    else
      add_message :error, "Utility Bill Master Record not found"
      return
    end
  end

  def update_and_submit
    BbpsBillerSubscription.status_ids(:draft, :rejected, :retracted).include?(bbps_subscription.status_id) && bbps_subscription.user_id == user.id
  end

  def edit
    (BbpsBillerSubscription.open_statuses.include?(bbps_subscription.status_id) && bbps_subscription.user_id == user.id) || (bbps_subscription.awaiting_approval? && bbps_subscription.get_reviewers.include?(user))
  end

  def policy_editable
    BbpsBillerSubscription.open_statuses.include?(bbps_subscription.status_id) && bbps_subscription.user_id == user.id
  end

  def retract
    bbps_subscription.awaiting_approval? && bbps_subscription.user_id == user.id
  end

  def approve
    bbps_subscription.awaiting_approval? && bbps_subscription.get_reviewers.include?(user)
  end

  def reject
    approve
  end

  def take_control
    bbps_subscription.awaiting_approval? && bbps_subscription.get_reviewers.exclude?(user) && user.vendor_payment_admin?
  end

  def return_control
    bbps_subscription.awaiting_approval? && bbps_subscription.get_reviewers.include?(user) && user.vendor_payment_admin? && has_taken_control?
  end

  def deactivate
    (bbps_subscription.approved? || bbps_subscription.auto_approved? || bbps_subscription.reactivated?) && user.vendor_payment_admin?
  end

  def reactivate
    bbps_subscription.deactivated? && user.vendor_payment_admin?
  end

  def add_bill
    BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated).include?(bbps_subscription.status_id) &&
        ["OPTIONAL", "NOT_SUPPORTED", nil].include?(bbps_subscription.fetch_requirement) && (bbps_subscription.pocs.include?(user) || bbps_subscription.user_id == user.id || user.vendor_payment_admin?)
  end

  def fetch_bill
    true if ["MANDATORY", "OPTIONAL"].include? bbps_subscription.biller.fetch_requirement
  end

  def raise_dispute
    BbpsBillerSubscription.status_ids(:approved, :auto_approved, :reactivated, :deactivated).include?(bbps_subscription.status_id)
  end

  def destroy
    (BbpsBillerSubscription.open_statuses.include?(bbps_subscription.status_id) && bbps_subscription.user_id == user.id)
  end

  private

  def has_taken_control?
    bbps_subscription.dlrms.where(level_id: bbps_subscription.controlling_level_id).map(&:taken_control_by_id).include?(user.id)
  end
end
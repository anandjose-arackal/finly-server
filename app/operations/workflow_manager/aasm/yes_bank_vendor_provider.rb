class WorkflowManager::Aasm::YesBankVendorProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :approved
    state :awaiting_approval
    # state :authorized
    state :rejected
    state :retracted
    state :auto_approved
    state :deactivated
    # todo add unapprove etc

    event :submit do
      transitions from: [:draft, :retracted, :rejected], to: :auto_approved, guard: [:reviewers_not_present?, :vendor_workflow_disabled?]
      transitions from: [:draft, :retracted, :rejected], to: :awaiting_approval, guard: [:reviewers_present?]
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
      transitions :from => :approved, :to => :awaiting_approval
    end

    event :take_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_is_admin?
    end

    event :return_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :reject do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :reject_to_level?
      transitions :from => :awaiting_approval, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :awaiting_approval, :to => :retracted
    end

    event :deactivate do
      transitions from: [:approved, :auto_approved], to: :deactivated 
    end

    event :reactivate do
      transitions from: :deactivated, to: :approved, guard: :reviewal_chain_present?
      transitions from: :deactivated, to: :auto_approved
    end

    after_all_events :change_state
  end

  def update_status
    super()
    if [:deactivate].include?(aasm.current_event)
      document.bank_accounts.update_all disabled: true
    end

    if [:reactivate].include?(aasm.current_event)
      document.bank_accounts.update_all disabled: false
    end
  end

  def vendor_workflow_disabled?
    !document.company.feature_subscription.vendor_empanelment_workflow
  end

  def user_is_admin?
    user.vendor_payment_admin?
  end

  def reviewal_chain_present?
    document.dlrms.present?
  end
end
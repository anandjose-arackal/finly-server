class WorkflowManager::Aasm::BbpsBillerSubscriptionProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :retracted
    state :awaiting_approval
    state :approved
    state :rejected
    state :auto_approved
    state :deactivated
    state :reactivated

    event :submit do
      transitions from: [:draft, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:draft, :retracted, :rejected], to: :awaiting_approval
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: [:user_can_unapprove?]
      transitions :from => :approved, :to => :awaiting_approval, guard: [:user_can_unapprove?]
    end

    event :hold do
      transitions :from => :awaiting_approval, :to => :hold
    end

    event :release do
      transitions :from => :hold, :to => :awaiting_approval
    end

    event :take_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
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

    event :deactivate do ## Confirm the action
      transitions :from => [:approved, :auto_approved, :reactivated], to: :deactivated
    end

    event :reactivate do ## Confirm the action
      transitions :from => :deactivated, :to => :reactivated
    end

    after_all_events :change_state
  end

  private

  def update_dlrms
    super
  end

  def update_levels
    super
  end

  def update_status
    super
  end
end
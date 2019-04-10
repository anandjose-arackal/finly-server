class WorkflowManager::Aasm::PurchaseRequestProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :retracted
    state :awaiting_approval
    state :approved
    state :rejected
    state :auto_approved
    state :closed
    state :cancelled
    state :order_initiated

    event :submit do
      transitions from: [:open, :retracted, :rejected, :draft], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected, :draft], to: :awaiting_approval
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_unapprove?
      transitions :from => :approved, :to => :awaiting_approval, guard: :user_can_unapprove?
    end

    event :take_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :return_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :reject do
      transitions :from => :awaiting_approval, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :awaiting_approval, :to => :retracted
      transitions :from => :approved, :to => :retracted
    end

    event :close do
      transitions :from => [:approved, :auto_approved], :to => [:closed]
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end
end
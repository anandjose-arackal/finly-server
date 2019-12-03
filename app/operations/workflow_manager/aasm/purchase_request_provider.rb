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
    state :po_created
    state :partially_closed
    state :po_void

    event :submit do
      # transitions from: [:open, :retracted, :rejected, :draft], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected, :draft], to: :awaiting_approval, guard: :reviewers_present?
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
      transitions :from => :closed, :to => :approved
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
      transitions :from => :approved, :to => :awaiting_approval
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
      transitions :from => :approved, :to => :rejected
    end

    event :retract do
      transitions :from => :awaiting_approval, :to => :retracted
      transitions :from => :approved, :to => :retracted
    end

    event :close do
      transitions :from => [:approved, :auto_approved, :po_created, :partially_closed], :to => [:closed]
    end

    event :po_creation do
      transitions :from => [:approved, :auto_approved], :to => [:po_created]
    end

    event :partially_close do
      transitions :from => [:approved, :auto_approved, :closed], :to => [:partially_closed]
    end

    event :po_void do
      transitions :from => [:po_created, :closed, :partially_closed], :to => [:approved]
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end
end
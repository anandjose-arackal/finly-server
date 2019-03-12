class WorkflowManager::Aasm::YesBankVendorProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :awaiting_approval
    state :authorized
    state :rejected
    state :auto_approved
    # todo add unapprove etc

    event :submit do
      transitions from: [:draft, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:draft, :rejected], to: :awaiting_approval
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
    end

    after_all_events :change_state
  end
end
class WorkflowManager::Aasm::BankPaymentRequestProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :credited
    state :creation_in_progress
    state :pending
    
    #[:open, :processing, :submitted, :retracted, :rejected, :approved, :unapprove, :credited, :pending, :creation_in_progress, :auto_approved]
    #:open, :processing, :submitted, :retracted, :rejected, :approved,
    # :unapprove, :credited, :pending, :creation_in_progress, :auto_approved

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => [:processing, :pending], :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => [:processing, :pending], :to => :processing, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :processing, :to => :processing, guard: [:user_can_unapprove?]
      transitions :from => :approved, :to => :processing, guard: [:user_can_unapprove?]
    end

    event :hold do
      transitions :from => :processing, :to => :hold
    end

    event :release do
      transitions :from => :hold, :to => :processing
    end

    event :take_control do
      transitions :from => :processing, :to => :processing
    end

    event :return_control do
      transitions :from => :processing, :to => :processing
    end

    event :reject do
      transitions :from => :processing, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :processing, :to => :retracted
    end

    event :credit do
      transitions from: [:open, :retracted, :rejected, :processing, :approved, :auto_approved], to: :credited
    end

    event :mark_as_credited do
      # Failed should be also added
      transitions from: [:approved, :auto_approved], to: :credited
    end

    after_all_events :change_state
  end
end

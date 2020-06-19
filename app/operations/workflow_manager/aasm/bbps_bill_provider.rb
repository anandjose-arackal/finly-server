class WorkflowManager::Aasm::BbpsBillProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :awaiting_approval
    state :approved
    state :rejected
    state :auto_approved
    state :payment_ticket_created
    state :paid
    state :failed
    state :voided
    state :expired


    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :awaiting_approval
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

    event :create_payment_ticket do
      transitions :from => [:approved, :awaiting_approval], :to => :payment_ticket_created
    end


    event :pay do ## Confirm the action
      transitions :from => :payment_ticket_created, to: :paid
      transitions :from => :payment_ticket_created, to: :failed
    end

    event :void do
      transitions from: [:approved, :auto_approved], :to => :voided
    end

    # for now just replicating void, will have to add other states later
    event :expire do
      transitions from: [:open, :awaiting_approval, :approved, :auto_approved, :payment_ticket_created, :payment_initiated], :to => :expired
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
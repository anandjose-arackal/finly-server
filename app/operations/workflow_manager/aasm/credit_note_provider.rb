class WorkflowManager::Aasm::CreditNoteProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :retracted
    state :awaiting_approval
    state :rejected
    state :approved
    state :auto_approved
    state :voided
    state :partially_adjusted
    state :adjusted

    event :submit do
      transitions from: [:draft, :retracted, :rejected], to: :awaiting_approval, guard: :reviewers_present?
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :reject do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :reject_to_level?
      transitions :from => :awaiting_approval, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :awaiting_approval, :to => :retracted
    end

    event :void do
      transitions :from => [:approved, :auto_approved], :to => [:voided]
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
      transitions :from => :approved, :to => :awaiting_approval
    end

    event :forward do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :take_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :return_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :adjust do
      # todo Write methods for determining partial adjustment
      transitions :from => [:approved, :auto_approved], :to => :adjusted, guard: :todo_action?
      transitions :from => [:approved, :auto_approved], :to => :partially_adjusted, guard: :todo_action?
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end

  private

  def todo_action?
    # todo
    # change action name
    # logic for determining whether credit note is being adjusted fully or partially
    # true
  end
end
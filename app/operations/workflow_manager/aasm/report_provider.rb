class WorkflowManager::Aasm::ReportProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :settled
    state :settlement_confirmed
    state :closed

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :closed, guard: [:reviewers_not_present?, :user_can_review?, :reimbursable_expenses_absent?]
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :processing, :to => :processing, guard: [:user_can_unapprove?]
      transitions :from => :approved, :to => :processing, guard: [:user_can_unapprove?]
      transitions :from => :closed, :to => :processing, guard: [:user_can_unapprove?]
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

    event :settle do ## Confirm the action
      transitions :from => [:approved, :auto_approved], to: :settled
    end

    event :settlement_confirm do ## Confirm the action
      transitions :from => [:settled], :to => [:settlement_confirmed]
    end

    event :close do
      transitions :from => [:approved, :auto_approved], to: :closed
    end

    event :mark_as_settled do ## Confirm action
      transitions from: :approved, to: :settled
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

  def reimbursable_expenses_absent?
    document.expenses.only_reimbursable_expenses.count == 0
  end
end
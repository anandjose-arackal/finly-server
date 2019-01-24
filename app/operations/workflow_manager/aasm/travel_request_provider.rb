class WorkflowManager::Aasm::TravelRequestProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :booked
    state :cancelled
    state :approved
    state :booking_pending
    state :auto_approved

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :booking_pending, guard: :tm_and_reviewers_not_present?
      transitions :from => :processing, :to => :approved, guard: :reviewers_not_present?
      transitions :from => :processing, :to => :processing
    end

    event :unapprove do
      transitions :from => :processing, :to => :processing
      transitions :from => :approved, :to => :processing
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
      transitions :from => :processing, :to => :rejected
    end

    event :retract do
      transitions :from => :processing, :to => :retracted
    end

    after_all_events :change_state
  end

  private

  def tm_and_reviewers_not_present?
    reviewers_not_present? && travel_managers_not_present?
  end

  def travel_managers_not_present?
    self.policy.policy_user_roles.with_role_id(UserRole.id_for(:travel_manager)).blank?
  end

  def change_state
    super
  end
end
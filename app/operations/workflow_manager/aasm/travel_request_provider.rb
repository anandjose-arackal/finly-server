class WorkflowManager::Aasm::TravelRequestProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :booked
    state :cancelled
    state :booking_pending
    state :selection_requested
    state :selection_processing
    state :selection_confirmed
    state :selection_rejected
    state :booking_confirmed
    state :completed

    #:open, :processing, :retracted, :rejected, :booked, :cancelled, :booking_pending,
    #:selection_requested, :selection_processing, :selection_confirmed, :selection_rejected,
    #:booking_confirmed, :completed, :approved, :auto_approved

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
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

    event :credit do ## Confirm the action
      transitions :from => [:approved, :auto_approved], to: :credited
      transitions :from => [:approved, :auto_approved], to: :pending
    end

    event :xxx do #todo write the action for moving from pending to credited
      transitions from: :pending, to: :credited
    end

    after_all_events :change_state
  end

  private

  def change_state
    super
  end
end
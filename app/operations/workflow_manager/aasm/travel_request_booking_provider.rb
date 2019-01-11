class WorkflowManager::Aasm::TravelRequestBookingProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :booking_pending, initial: true, :before_enter => :set_state
    state :selection_requested
    state :selection_processing
    state :selection_confirmed
    state :selection_rejected
    state :booking_confirmed
    state :completed

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :request_selection do
      transitions from: [:booking_pending], to: :selection_requested
    end

    # event :request

    after_all_events :change_state
  end

  private

  def change_state
    super
  end
end
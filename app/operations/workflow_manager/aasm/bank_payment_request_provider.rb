class WorkflowManager::Aasm::BankPaymentRequestProvider < WorkflowManager::Aasm::Base
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
    #:open, :processing, :submitted, :retracted, :rejected, :approved,
    # :unapprove, :credited, :pending, :creation_in_progress, :auto_approved

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

    event :settle do ## Confirm the action
      transitions :from => [:approved, :auto_approved], to: :settled
    end

    event :confirm_settlement do ## Confirm the action
      transitions :from => [:settled], :to => [:settlement_confirmed]
    end

    event :close do ## Confirm action
      # Check from what all states it can transition
      transitions :from => [:approved], to: :closed
    end

    after_all_events :change_state
  end

  private

  # def set_state
  #   aasm.current_state = self.document_state
  # end

  def change_state
    super
    # Change state of purchase order
    report_status_id = ::ReportStatus.id_for(self.aasm.current_state)
    update_params = {
        report_status_id: report_status_id,
        controlling_level_id: self.new_level&.id
    }
    self.document.update(update_params)
  end
end
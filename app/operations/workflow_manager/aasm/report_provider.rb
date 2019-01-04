class WorkflowManager::Aasm::ReportProvider < WorkflowManager::Aasm::Base

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
      transitions :from => :processing, :to => :approved, guard: :reviewers_not_present?
      transitions :from => :processing, :to => :processing
    end

    event :unapprove do
      transitions :from => :processing, :to => :processing
      transitions :from => :approved, :to => :processing
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
      transitions :from => [:settlement_confirmed], to: :settled
    end

    after_all_events :change_state
  end

  private

  # def set_state
  #   aasm.current_state = self.document_state
  # end

  def change_state
    # Update Document Level Reviewer Mapping
    # find current document_level_reviewer_mappings
    if [:approve, :reject].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
                 .where(level_id: current_level.id, policy_id: document.policy.id)
                 .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first

      if dlrm.present?
        dlrm.update({
                        action_id: TrailAction.id_for(aasm.current_event),
                        viewable: true,
                        action_taken_by_id: user.id

                    })
      end
    end

    if [:take_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: user.id, taken_control: true)
      end
    end

    if [:retract].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
      dlrm.update_all(
          taken_control: false,
          taken_control_by_id: nil,
          action_taken_by_id: nil,
          action_id: nil
      )
    end

    if [:reject].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings
      dlrm.update_all(
              taken_control: false,
              taken_control_by_id: nil,
              action_taken_by_id: nil,
              action_id: nil
      )
    end

    # reset levels
    # if [:retract, :reject].include?(aasm.current_event)
    #   self.new_level = nil
    # end
    if [:submit, :approve].include?(aasm.current_event)
      self.new_level = self.next_level
    end

    if [:take_control].include?(aasm.current_event)
      self.new_level = self.current_level
    end

    if [:unapprove].include?(aasm.current_event)
      self.new_level = self.previous_level
    end



    # Change state of purchase order
    report_status_id = ::ReportStatus.id_for(self.aasm.current_state)
    update_params = {
        report_status_id: report_status_id,
        controlling_level_id: self.new_level&.id
    }
    if self.document.update(update_params)
      p document.controlling_level_id
    end
  end
end
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
      transitions :from => [:pending,:processing], :to => :processing
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
      transitions from: [:open, :retracted, :rejected, :processing, :approved, :auto_approved], to: :credited
    end

    after_all_events :change_state
  end


  def update_dlrms
    super

    # If Credit then mark all next level active:false & set controlling level to nil
    if [:credit, :mark_as_credited].include?(aasm.current_event)
      if current_level.present?
        # Update current dlrm with action
        dlrm = document.document_level_reviewer_mappings.with_level_id(current_level.id)
                   .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first
        if dlrm.present?
          dlrm.update(
            action_id: TrailAction.id_for(aasm.current_event),
            action_taken_by_id: user.id
          )
        end

        # Update next dlrms as active false
        current_level_number = current_level.level_number
        dlrms = document.document_level_reviewer_mappings.with_level_number_gt(current_level_number)

        if dlrms.present?
          dlrms.update_all(active: false)
        end
      end
    end
  end

  def update_levels
    super

    if [:credit].include?(aasm.current_event)
      self.new_level = nil
    end
  end
end

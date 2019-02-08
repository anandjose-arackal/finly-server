class WorkflowManager::Aasm::MoneyRequestProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :credited
    state :pending

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: :reviewers_not_present?
      transitions :from => :processing, :to => :processing, guard: [:user_can_approve?]
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
      transitions :from => :processing, to: :credited
      transitions :from => [:approved, :auto_approved], to: :credited
      transitions :from => [:approved, :auto_approved], to: :pending
    end

    event :xxx do #todo write the action for moving from pending to credited
      transitions from: :pending, to: :credited
    end

    after_all_events :change_state
  end

  private

  # def set_state
  #   aasm.current_state = self.document_state
  # end

  def update_dlrms
    super

    if [:credit].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_level_id(current_level.id).with_policy_id(policy.id)
                .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first

      if dlrm.present?
        dlrm.update(
                action_id: TrailAction.id_for(aasm.current_event),
                action_taken_by_id: user.id
        )

        dlrms = document.document_level_reviewer_mappings.where('level_number > ?', dlrm.level_number)

        dlrms.update_all(active: false)
      end
    end
  end

end
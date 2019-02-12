class WorkflowManager::Aasm::TravelRequestBookingProvider < WorkflowManager::Aasm::BaseProvider

  def initialize(document, violation_present, user, provider_name=nil)
    self.document = document
    self.violations_present = violations_present
    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.user = user
    self.policy = self.document.policy ## Have to take care where status is stored in a different attribute

    self.provider_name = 'TravelRequestBookingProvider'

    # get reviewers
    self.current_level = document.get_level(:current, provider_name)
    self.next_level = document.get_level(:next, provider_name)
    self.previous_level = document.get_level(:prev, provider_name)
    self.current_level_reviewers = document.get_reviewers(:current, provider_name)
    self.reviewers = document.get_reviewers(:next, provider_name)
    self.document_update_params = {}
  end

  aasm :whiny_transitions => false do
    state :booking_pending, initial: true, :before_enter => :set_state
    state :selection_requested
    state :selection_processing
    state :selection_confirmed
    state :selection_rejected
    state :booking_confirmed
    state :completed

    event :request_selection do # Done by the travel manager to the employee
      transitions from: [:booking_pending], to: :selection_requested
    end

    event :confirm_selection do # Equivalent to submit
      transitions from: [:selection_requested, :selection_rejected], to: :selection_confirmed, guard: :reviewers_not_present?
      transitions from: [:selection_requested, :selection_rejected], to: :selection_processing
    end

    event :approve_selection do
      transitions from: [:selection_processing], to: :selection_confirmed, guard: [:reviewers_not_present?, :user_can_review?]
      transitions from: [:selection_processing], to: :selection_processing, guard: :user_can_review?
    end

    # event :unapprove_selection do
    #   transitions from: [:selection_processing], to: :selection_processing
    # end

    event :take_control do
      transitions from: :selection_processing, to: :selection_processing
    end

    event :return_control do
      transitions from: :selection_processing, to: :selection_processing
    end

    event :reject_selection do
      transitions from: :selection_processing, to: :selection_rejected
    end

    event :confirm_booking do
      # MoneyRequestProvider depends on this to mark money requests to approved form pending status
      transitions from: :selection_confirmed, to: :booking_confirmed
    end

    # event :request
    after_all_events :change_state
  end

  private

  def update_dlrms
    if[:confirm_selection].include?(aasm.current_event)
      self.document_update_params[:booking_submitted_at] = DateTime.now
      dlrms = document.document_level_reviewer_mappings.with_provider_name(provider_name).with_level_id(next_level&.id).with_policy_id(policy.id)

      # Set viewable true for the next level when document is submitted
      if dlrms.present?
        dlrms.update_all(viewable: true)
      end
    end

    # Update Document Level Reviewer Mapping
    # find current document_level_reviewer_mappings
    if [:approve_selection, :reject_selection].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name).with_level_id(current_level.id).with_policy_id(policy.id)
                 .where("taken_control_by_id = ? or reviewer_id = ?", user.id, user.id).first

      if dlrm.present?
        dlrm.update(
            action_id: TrailAction.id_for(aasm.current_event),
            action_taken_by_id: user.id
        )
      end
    end

    if [:approve_selection].include?(aasm.current_event)
      if next_level.present?
        next_dlrms = document.document_level_reviewer_mappings.with_provider_name(provider_name).with_level_id(next_level.id).with_policy_id(policy.id)
        next_dlrms.update_all(viewable: true)
      else
        self.document_update_params[:booking_approved_at] = DateTime.now
      end
    end

    if [:unapprove_selection].include?(aasm.current_event)
      unapprove_level = previous_level.present? ? previous_level : current_level
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name)
        .where(level_id: unapprove_level&.id, policy_id: document.policy.id).where.not(action_taken_by_id: nil).first

      dlrm.update(
          action_taken_by_id: nil,
          action_id: TrailAction.id_for(aasm.current_event)
      )

    end

    if [:take_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name)
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: user.id, taken_control: true)
      end
    end

    if [:return_control].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name)
          .where(level_id: current_level.id, policy_id: document.policy.id)

      if dlrm.present?
        dlrm.update_all(taken_control_by_id: nil, taken_control: false)
      end
    end

    if [:retract_selection].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name)
      dlrm.update_all(
          taken_control: false,
          taken_control_by_id: nil,
          action_taken_by_id: nil,
          action_id: nil
      )
    end

    if [:reject_selection].include?(aasm.current_event)
      dlrm = document.document_level_reviewer_mappings.with_provider_name(provider_name)
      dlrm.update_all(
              taken_control: false,
              taken_control_by_id: nil,
              action_taken_by_id: nil,
              action_id: nil
      )
    end
  end

  def update_levels
    # :retract_selection & :reject_selection should set level to nil; which it already is

    # :submit & :approve should move to next level
    if [:confirm_selection, :approve_selection].include?(aasm.current_event)
      self.new_level = self.next_level
    end

    # :take_control and :return_control should remain in the same level
    if [:take_control, :return_control].include?(aasm.current_event)
      self.new_level = self.current_level
    end

    # :unapprove should move one level back
    if [:unapprove_selection].include?(aasm.current_event)
      self.new_level = self.previous_level
    end
  end

  def update_status
    status_id = document.status.class.id_for(self.aasm.current_state)
    generate_update_params

    self.document_update_params[:controlling_level_id] = self.new_level&.id

    self.document_update_params[document.class.document_status_attribute] = status_id
    self.document.update(self.document_update_params)
  end

  def generate_update_params
    if [:request_selection].include?(aasm.current_event)
      self.document_update_params[:submitted_at] = DateTime.now
    end

    if [:confirm_booking].include?(aasm.current_event)
      self.document_update_params[:booking_confirmed_at] = DateTime.now
    end
  end

  def user_can_review?
    # todo
    self.document.action_users(:approve, provider_name)

  end
end

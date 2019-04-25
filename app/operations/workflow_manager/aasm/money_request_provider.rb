class WorkflowManager::Aasm::MoneyRequestProvider < WorkflowManager::Aasm::BaseProvider

  def initialize(user, params)
    self.user = user

    self.document = params[:document]
    self.violations_present = params[:violations_present]
    self.forwarded_to_user = params[:forwarded_to_user]
    self.provider_name = params[:provider_name] || self.document.get_default_provider

    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.policy_id = self.document.policy_id
    self.policy = Policy.find_by id: policy_id ## Have to take care where status is stored in a different attribute

    # get reviewers
    self.current_level = document.level
    self.next_level = document.get_level(:next, provider_name)
    self.previous_level = document.get_level(:prev, provider_name)
    self.current_level_reviewers = document.get_reviewers(:current, provider_name)
    self.reviewers = document.get_reviewers(:next, provider_name)
    self.document_update_params = {}
  end


  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :credited
    state :pending
    state :trip_open
    state :trip_processing
    state :trip_retracted
    state :trip_rejected
    state :trip_approved

    event :submit do
      transitions from: [:trip_open, :trip_retracted, :trip_rejected], to: :trip_approved, guard: [:reviewers_not_present?, :travel_request_present?]
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?

      transitions from: [:trip_open, :trip_retracted, :trip_rejected], to: :trip_processing, guard: [:travel_request_present?]
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :trip_processing, :to => :trip_approved, guard: [:reviewers_not_present?, :user_can_review?, :travel_request_present?]
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
    end

    event :confirm_booking do
      transitions :from => :trip_approved, :to => :approved, guard: [:travel_request_present?, :travel_request_booking_confirmed?]
    end

    event :unapprove do
      transitions :from => :trip_processing, :to => :trip_processing, guard: [:travel_request_present?, :user_can_unapprove?]
      transitions :from => :trip_approved, :to => :trip_processing, guard: [:travel_request_present?, :user_can_unapprove?]
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
      transitions :from => :trip_processing, :to => :trip_processing, guard: [:travel_request_present?]
      transitions :from => :processing, :to => :processing
    end

    event :return_control do
      transitions :from => :trip_processing, :to => :trip_processing, guard: [:travel_request_present?]
      transitions :from => :processing, :to => :processing
    end

    event :reject do
      transitions :from => :trip_processing, :to => :trip_rejected, guard: [:user_can_review?, :travel_request_present?]
      transitions :from => :processing, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :trip_processing, :to => :trip_retracted, guard: [:travel_request_present?]
      transitions :from => :processing, :to => :retracted
    end

    event :credit do
      transitions :from => :processing, to: :credited, guard: [:user_can_review?]
      transitions :from => [:approved, :auto_approved], to: :credited
      # transitions :from => [:approved, :auto_approved], to: :pending # Pending was used in travel request.
    end

    event :mark_as_credited do #todo check if mark as credited should do this
      transitions :from => [:approved, :auto_approved], to: :credited
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
      if current_level.present?
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

  def travel_request_present?
    self.document.travel_request.present?
  end

  def travel_request_booking_confirmed?
    self.document.travel_request.status.id == TravelRequestStatus.id_for(:booking_confirmed)
  end
end

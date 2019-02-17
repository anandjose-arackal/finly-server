class WorkflowManager::Aasm::TravelRequestProvider < WorkflowManager::Aasm::BaseProvider

  def initialize(document, violation_present, user, provider_name=nil)
    self.document = document
    self.violations_present = violations_present
    self.aasm.current_state = self.document.status.name.downcase.to_sym ## Have to take care where status is stored in a different attribute
    self.user = user
    self.policy = self.document.policy ## Have to take care where status is stored in a different attribute

    self.provider_name = provider_name || self.document.get_default_provider

    # get reviewers
    self.current_level = document.get_level(:current, provider_name)
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
      transitions :from => :processing, :to => :booking_pending, guard: [:reviewers_not_present?, :travel_manager_present?]
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
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

    after_all_events :change_state
  end

  private

  def travel_manager_present?
    self.document.document_role_users(:travel_managers).present?
  end

  def travel_managers_not_present?
    self.policy.policy_user_roles.with_role_id(UserRole.id_for(:travel_manager)).blank?
  end

  def change_state
    super
  end
end

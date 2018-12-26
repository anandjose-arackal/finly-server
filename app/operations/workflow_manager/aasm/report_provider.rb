class WorkflowManager::Aasm::ReportProvider < WorkflowManager::Aasm::Base
  # If policy not present auto approve
  #

  # include AASM
  # attr_accessor :document_state, :document, :user, :violations_present, :policy, :current_level, :next_level
  #
  # def initialize(document, violations_present, user)
  #   self.document = document
  #   self.violations_present = violations_present
  #   self.aasm.current_state = self.document.status.name.to_sym ## Have to take care where status is stored in a different attribute
  #   self.user = user
  #   self.policy = self.document.policy ## Have to take care where status is stored in a different attribute
  #   set_levels
  # end

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
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :approvers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: :approvers_not_present?
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

  def set_state
    aasm.current_state = self.document_state
  end

  def change_state
    # reset levels
    if [:retract, :reject].include?(aasm.current_event)
      self.next_level = nil
    end

    if [:retract].include?(aasm.current_event)
      self.current_level = nil
    end

    if [:unapprove].include?(aasm.current_event)
      self.next_level = previous_level
    end

    # Change state of purchase order
    purchase_order_status_id = ::PurchaseOrderStatus.id_for(self.aasm.current_state)
    update_params = {
        purchase_order_status_id: purchase_order_status_id,
        controlling_level_id: self.next_level&.id
    }
    self.purchase_order.update(update_params)
  end
end
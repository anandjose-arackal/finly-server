class WorkflowManager::Aasm::PurchaseOrder < WorkflowManager::Aasm::Base
  # If policy not present auto approve
  #

  include AASM
  attr_accessor :po_state, :purchase_order, :user, :violations_present

  def initialize(purchase_order, violations_present, user)
    self.purchase_order = purchase_order
    self.violations_present = violations_present
    self.aasm.current_state = self.purchase_order.status.name.to_sym
    self.user = user
    self.policy = purchase_order.policy
  end

  aasm :whiny_transitions => false do
    state :open
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :sent_to_vendor
    state :closed

    event :submit do
      transitions from: [:open, :retracted], to: :auto_approved, guard: :approvers_not_present?
      transitions :from => [:open, :retracted], :to => :processing
    end

    event :approve do
      transitions :from => :processing, :to => [:processing, :approved]
    end

    event :reject do
      transitions :from => :processing, :to => :rejected
    end

    event :retract do
      transitions :from => :processing, :to => :retracted
    end

    event :send_to_vendor do
      transitions from: :approved, to: :sent_to_vendor
    end

    event :close do
      transitions :from => [:approved, :sent_to_vendor], :to => [:closed]
    end

    after_all_transitions :change_state
  end

  private

  def aasm_ensure_initial_state
    self.aasm_state = self.po_state
  end

  def check_controlling_user
    true
  end

  def create_trail
  end

  def approvers_not_present?
    if self.policy.present?

    else
      false
    end
  end


  def next_level
    levels = self.policy.levels.with_entity_type(purchase_order.class.name)


  end
end
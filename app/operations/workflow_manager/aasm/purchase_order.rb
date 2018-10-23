class WorkflowManager::Aasm::PurchaseOrder < WorkflowManager::Aasm::Base
  # If policy not present auto approve
  #

  include AASM
  attr_accessor :po_state, :purchase_order, :user, :violations_present, :policy, :current_level, :next_level

  def initialize(purchase_order, violations_present, user)
    self.purchase_order = purchase_order
    self.violations_present = violations_present
    self.aasm.current_state = self.purchase_order.status.name.to_sym
    self.user = user
    self.policy = self.purchase_order.policy
    set_levels
  end

  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :sent_to_vendor
    state :closed

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :approvers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: :approvers_not_present?
      transitions :from => :processing, :to => :processing
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

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end

  private

  def set_state
    aasm.current_state = self.po_state
  end

  def change_state
    # reset levels
    if [:retract, :reject].include?(aasm.current_event)
      self.next_level = nil
    end

    if [:retract].include?(aasm.current_event)
      self.current_level = nil
    end

    # Change state of purchase order
    purchase_order_status_id = ::PurchaseOrderStatus.id_for(self.aasm.current_state)
    update_params = {
        purchase_order_status_id: purchase_order_status_id,
        controlling_level_id: self.next_level&.id
    }
    self.purchase_order.update(update_params)
  end

  def approvers_not_present?
    if self.policy.present?
      if self.next_level.present?
        if self.next_level.level_reviewer_mappings.with_threshold(self.purchase_order.balance_amount.value).present?
          return false
        else
          return true
        end
      else
        return true
      end
    else
      true
    end
  end

  def set_levels
    # total_amount = purchase_order.total_amount
    self.current_level = ReviewalLevel.with_id(purchase_order.controlling_level_id).first
    level_number = current_level.present? ? (current_level.level_number + 1) : 1
    self.next_level = self.policy.levels.with_entity_type(purchase_order.class.name).with_level_number(level_number).first
  end
end
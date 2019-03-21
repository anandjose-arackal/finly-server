class WorkflowManager::Aasm::PurchaseOrderProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :sent_to_vendor
    state :closed
    state :voided
    # todo add unapprove etc

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
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
      transitions :from => :processing, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :processing, :to => :retracted
    end

    event :send_to_vendor do
      transitions :from => [:approved, :auto_approved], to: :sent_to_vendor
    end

    event :close do
      transitions :from => [:approved, :auto_approved, :sent_to_vendor], :to => [:closed]
    end

    event :void do
      transitions :from => [:approved, :auto_approved, :sent_to_vendor, :closed], to: :voided
    end

    event :reopen do
      transitions from: :closed, to: :auto_approved, guard: :is_auto_approve?
      transitions from: :closed, to: :approved, guard: :is_approve?
      transitions from: :closed, to: :sent_to_vendor, guard: :is_send_to_vendor?
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end

  private

  def user_is_admin?
    user.vendor_payment_admin?
  end

  def previous_state
    ps = self.document.trails.where(action_id: [5,7,33])
    ps.last.action_id
  end

  def is_approve?(state=false)
    ps_id = previous_state
    state = ( ps_id == 5 ) ? true : false
  end

  def is_auto_approve?(state=false)
    ps_id = previous_state
    state = ( ps_id == 7 ) ? true : false
  end

  def is_send_to_vendor?(state=false)
    ps_id = previous_state
    state = ( ps_id == 33 ) ? true : false
  end

  #
  # # def set_state
  # #   aasm.current_state = self.po_state
  # # end
  # #
  # # def change_state
  # #   # reset levels
  # #   if [:retract, :reject].include?(aasm.current_event)
  # #     self.next_level = nil
  # #   end
  # #
  # #   if [:retract].include?(aasm.current_event)
  # #     self.current_level = nil
  # #   end
  # #
  # #   if [:unapprove].include?(aasm.current_event)
  # #     self.next_level = previous_level
  # #   end
  # #
  # #   # Change state of purchase order
  # #   purchase_order_status_id = ::PurchaseOrderStatus.id_for(self.aasm.current_state)
  # #   update_params = {
  # #       purchase_order_status_id: purchase_order_status_id,
  # #       controlling_level_id: self.next_level&.id
  # #   }
  # #   self.purchase_order.update(update_params)
  # # end
  #
  # # def approvers_not_present?
  # #   if self.policy.present?
  # #     if self.next_level.present?
  # #       if self.next_level.level_reviewer_mappings.with_threshold(self.purchase_order.balance_amount.value).present?
  # #         return false
  # #       else
  # #         return true
  # #       end
  # #     else
  # #       return true
  # #     end
  # #   else
  # #     true
  # #   end
  # # end
  #
  # # def set_levels
  # #   # total_amount = purchase_order.total_amount
  # #   self.current_level = ReviewalLevel.with_id(purchase_order.controlling_level_id).first
  # #   level_number = current_level.present? ? (current_level.level_number + 1) : 1
  # #   self.next_level = self.policy.levels.with_entity_type(purchase_order.class.name).with_level_number(level_number).first
  # # end
  # #
  # # def previous_level
  # #   self.current_level = ReviewalLevel.with_id(purchase_order.controlling_level_id).first
  # #   if current_level.present? && current_level.level_number > 1
  # #     level_number = current_level.level_number - 1
  # #     level = self.policy.levels.with_entity_type(purchase_order.class.name).with_level_number(level_number).first
  # #   else
  # #     level = nil
  # #   end
  # #   level
  # # end
end
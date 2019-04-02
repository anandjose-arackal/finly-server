class WorkflowManager::Aasm::InvoiceProvider < WorkflowManager::Aasm::BaseProvider

  aasm :whiny_transitions => false do
    state :open, initial: true, :before_enter => :set_state
    state :retracted
    state :processing
    state :approved
    state :rejected
    state :auto_approved
    state :closed
    state :unpaid
    state :partially_paid
    state :paid

    event :submit do
      transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
    end

    event :reject do
      transitions :from => :processing, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :processing, :to => :retracted
    end

    event :close do
      transitions :from => [:approved, :auto_approved], :to => [:closed]
    end

    event :unapprove do
      transitions :from => :processing, :to => :processing
      transitions :from => :approved, :to => :processing
    end

    event :take_control do
      transitions :from => :processing, :to => :processing
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end

  private

  def set_state
    aasm.current_state = self.invoice_state
  end

  # def change_state
  #   super
  #
  #   status_id = ::InwardInvoiceStatus.id_for(self.aasm.current_state)
  #   update_params = {
  #       invoice_status_id: status_id,
  #       controlling_level_id: self.next_level&.id
  #   }
  #   self.document.update(update_params)
  # end

  # def approvers_not_present?
  #   if self.policy.present?
  #     if self.next_level.present?
  #       if self.next_level.level_reviewer_mappings.with_threshold(self.invoice.net_amount.value).present?
  #         return false
  #       else
  #         return true
  #       end
  #     else
  #       return true
  #     end
  #   else
  #     true
  #   end
  # end

  # def set_levels
  #   self.current_level = ReviewalLevel.with_id(invoice.controlling_level_id).first
  #   level_number = current_level.present? ? (current_level.level_number + 1) : 1
  #
  #   self.next_level = self.policy.levels.with_entity_type(invoice.class.name).with_level_number(level_number).first
  # end
end
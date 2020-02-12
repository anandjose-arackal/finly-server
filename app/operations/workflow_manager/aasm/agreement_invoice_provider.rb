class WorkflowManager::Aasm::AgreementInvoiceProvider < WorkflowManager::Aasm::BaseProvider

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
    state :void

    event :submit do
      # transitions from: [:open, :retracted, :rejected], to: :auto_approved, guard: :reviewers_not_present?
      transitions from: [:open, :retracted, :rejected], to: :processing, guard: :reviewers_present?
    end

    event :approve do
      transitions :from => :processing, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
    end

    event :reject do
      transitions :from => :processing, :to => :processing, guard: :reject_to_level?
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

    event :forward do
      transitions :from => :processing, :to => :processing, guard: :user_can_review?
    end

    event :take_control do
      transitions :from => :processing, :to => :processing
    end

    event :return_control do
      transitions :from => :processing, :to => :processing
    end

    event :paid do
      transitions :from => [:approved, :auto_approved], :to => :paid, guard: :balance_due_is_zero?
    end

    event :void do
      transitions :from => [:approved, :auto_approved], to: :voided, guard: [:user_is_admin?, :no_payments?]
    end

    after_all_events :change_state
    # after_all_transitions :log_status_change
    # success :change_state
  end

  private

  def set_state
    aasm.current_state = self.invoice_state
  end

  def balance_due_is_zero?
    # if invoice final amount comes to zero, probably because so much advance was adjusted, then auto mark it as paid
    document.balance_due&.value == 0
  end

  def user_is_admin?
    user.vendor_payments_admin?
  end

  def no_payments?
    document.payments.blank?
  end
end
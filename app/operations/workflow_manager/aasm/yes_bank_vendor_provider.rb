class WorkflowManager::Aasm::YesBankVendorProvider < WorkflowManager::Aasm::BaseProvider
  aasm :whiny_transitions => false do
    state :draft, initial: true, :before_enter => :set_state
    state :approved
    state :awaiting_approval
    # state :authorized
    state :rejected
    state :retracted
    state :auto_approved
    state :deactivated
    # todo add unapprove etc

    event :submit do
      transitions from: [:draft, :retracted, :rejected], to: :auto_approved, guard: [:reviewers_not_present?, :vendor_workflow_disabled?]
      transitions from: [:draft, :retracted, :rejected], to: :awaiting_approval, guard: [:reviewers_present?]
    end

    event :approve do
      transitions :from => :awaiting_approval, :to => :approved, guard: [:reviewers_not_present?, :user_can_review?]
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_can_review?
    end

    event :unapprove do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
      transitions :from => :approved, :to => :awaiting_approval
    end

    event :take_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :user_is_admin?
    end

    event :return_control do
      transitions :from => :awaiting_approval, :to => :awaiting_approval
    end

    event :reject do
      transitions :from => :awaiting_approval, :to => :awaiting_approval, guard: :reject_to_level?
      transitions :from => :awaiting_approval, :to => :rejected, guard: :user_can_review?
    end

    event :retract do
      transitions :from => :awaiting_approval, :to => :retracted
    end

    event :deactivate do
      transitions from: [:approved, :auto_approved], to: :deactivated 
    end

    event :reactivate do
      transitions from: :deactivated, to: :approved, guard: [:reviewal_chain_present?, :validate_vendor]
      transitions from: :deactivated, to: :auto_approved, guard: [:validate_vendor]
    end

    after_all_events :change_state
  end

  def update_status
    super()
    if [:deactivate].include?(aasm.current_event)
      document.bank_accounts.update_all disabled: true
    end

    if [:reactivate].include?(aasm.current_event)
      document.bank_accounts.update_all disabled: false
    end
  end

  def vendor_workflow_disabled?
    !document.company.feature_subscription.vendor_empanelment_workflow
  end

  def user_is_admin?
    user.vendor_payment_admin?
  end

  def validate_vendor
    similar_pan_vendors = YesBankVendor.where(pan: document.pan, company_id: user.company_id).filter_active
    if similar_pan_vendors.present?
      self.messages[:error].push "Vendor with pan: \"#{similar_pan_vendors.first.pan}\" already exists in the system. See vendor - #{similar_pan_vendors.first.display_name}"
      return false
    end
    similar_bank_accounts = BankAccount.where(account_number: document.bank_accounts.pluck(:account_number), company_id: user.company_id).filter_active
    if similar_bank_accounts.present?
      self.messages[:error].push "Active Bank Account with account number \"#{similar_bank_accounts.first.account_number}\" already exists in the system. Please disable it. See vendor - #{similar_bank_accounts.first.account_owner.display_name}"
      return false
    end
    document_gstins = document.gstin_locations.pluck(:gstin)&.reject { |c| c.empty? }
    similar_gstins = GstinLocation.where(vendor_id: user.company.yes_bank_vendors.non_deleted.filter_active).where(gstin: document_gstins)
    if similar_gstins.present?
      self.messages[:error].push "GSTIN details for \"#{similar_gstins.first.gstin}\" already exists in the system. See vendor - #{similar_gstins.first.vendor.display_name}"
      return false
    end
    true
  end

  def reviewal_chain_present?
    document.dlrms.present?
  end
end
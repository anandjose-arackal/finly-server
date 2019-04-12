class Policy::ApprovalWorkflows::IndexUserLevel < Policy::ApprovalWorkflows::Base
  attr_accessor :reviewal_levels, :policy_users, :policy, :provider

  class Policy::ApprovalWorkflows::IndexUserLevel::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reviewal_levels, :policy_users, :paginated_users, :levels_data, :count

    has_scope :filter_policy
    has_scope :filter_associated_entity_type
    # has_scope :reviewal_level_id

    def init
      self.policy_users = params[:policy_users]
      self.reviewal_levels = params[:reviewal_levels]

      if self.reviewal_levels.present?
        self.reviewal_levels = apply_scopes(self.reviewal_levels, params)
        self.reviewal_levels = self.reviewal_levels.non_deleted
        self.reviewal_levels = self.reviewal_levels.reorder(:level_number)
      end

      self.levels_data = []
      self.reviewal_levels.each do |level|
        lrms = level.level_reviewer_mappings.non_deleted
        data = {
          level_number: level.level_number,
          id: level.id,
          level: level,
          lrms: lrms
        }
        self.levels_data.push(data)
      end

      self.count = self.policy_users.count
      page = (params[:page] || 1)
      per_page = (params[:per_page] || 30)
      self.paginated_users = self.policy_users.paginate(page: page, per_page: per_page)
    end
  end

  def authorized_user_types
    [:admin, :vendor_payments_admin]
  end

  def init
    policy_id = params[:policy_id]
    self.provider = params[:filter_associated_entity_type]
    self.policy = user.company.policies.find_by(id: policy_id)

    unless self.policy.present?
      add_message :error, "Policy not found"
    end

    self.reviewal_levels = ReviewalLevel.with_policy_ids(self.policy.id)
    user_ids = scope_users_by_role
    self.policy_users = User.where(id: user_ids)
  end

  def validate
    
  end

  def success
    params[:policy_users] = self.policy_users
    params[:reviewal_levels] = self.reviewal_levels
    Policy::ApprovalWorkflows::IndexUserLevel::IndexPresenter.new(user, params, messages)
  end

  def scope_users_by_role
    if provider.present?
      case provider
      when 'PurchaseOrderProvider', :PurchaseOrderProvider
        user_ids = PolicyUserRole.where(policy_id: policy.id, user_role_id: UserRole.id_for(:purchase_order_initiator)).pluck(:user_id).uniq rescue []
        user_ids += [user.id] if user.vp_admin_or_auditor? && user_ids.exclude?(user.id)
      when 'InvoiceProvider', :InvoiceProvider
        user_ids = PolicyUserRole.where(policy_id: policy.id, user_role_id: UserRole.id_for(:invoice_initiator)).pluck(:user_id).uniq rescue []
        user_ids += [user.id] if user.vp_admin_or_auditor? && user_ids.exclude?(user.id)
      when 'BankPaymentRequestProvider', :BankPaymentRequestProvider
        user_ids = PolicyUserRole.where(policy_id: policy.id, user_role_id: UserRole.id_for(:bank_payment_request_initiator)).pluck(:user_id).uniq rescue []
        user_ids += [user.id] if user.vp_admin_or_auditor? && user_ids.exclude?(user.id)
      when 'PurchaseRequestProvider', :PurchaseRequestProvider
        user_ids = PolicyUserRole.where(policy_id: policy.id, user_role_id: UserRole.id_for(:purchase_request_initiator)).pluck(:user_id).uniq rescue []
        user_ids += [user.id] if user.vendor_payments_admin? && user_ids.exclude?(user.id)
      when 'MoneyRequestProvider', 'ReportProvider', 'TravelRequestBookingProvider', 'TravelRequestProvider', :MoneyRequestProvider, :ReportProvider, :TravelRequestProvider, :TravelRequestBookingProvider
        user_ids = User.with_id(self.policy.user_mapping.non_deleted.pluck(:user_id)) rescue []
      end
      return user_ids
    end
  end
end
class Vendors::Index < Vendors::Base

  attr_accessor :vendors

  class Vendors::Index::VendorsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :vendors, :count, :paginated_vendors

    has_scope :filter_name_search
    has_scope :filter_search
    has_scope :filter_vendor_type_id
    has_scope :filter_status_id
    has_scope :filter_policy_id
    has_scope :filter_created_by_id
    has_scope :filter_account_details
    has_scope :filter_business_name
    has_scope :filter_vendor_id
    has_scope :filter_approved, type: :boolean
    has_scope :non_deleted, type: :boolean
    has_scope :filter_active, type: :boolean
    has_scope :authorized, type: :boolean
    has_scope :filter_gstin
    has_scope :filter_pan

    has_scope :sort_vendor_id
    has_scope :sort_created_at
    has_scope :sort_business_name

    def init
      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, params)
      self.vendors = self.vendors.sort_for_index

      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_vendors = self.vendors.paginate(page: page, per_page: per_page).include_details
      self.count = self.vendors.count
    end

    def get_counts
      result = {
        all: 0,
        open: 0,
        approved: 0,
        deactivated: 0,
        processing: 0,
        awaiting_approval: 0
      }

      vendor_status_ids = YesBankVendor.status_ids(:draft, :awaiting_approval, :retracted, :rejected, :approved, :auto_approved, :deactivated)
      vendor_status_counts = self.vendors.where(status_id: vendor_status_ids)&.group(:status_id)&.count

      result[:all] = self.vendors.count

      VendorStatus.all.map do |status|
        case status.id
        when VendorStatus.id_for(:draft), VendorStatus.id_for(:retracted), VendorStatus.id_for(:rejected)
          result[:open] += (vendor_status_counts[status.id] || 0)
        when VendorStatus.id_for(:awaiting_approval)
          result[:processing] += (vendor_status_counts[status.id] || 0)
        when VendorStatus.id_for(:approved), VendorStatus.id_for(:auto_approved) 
          result[:approved] += (vendor_status_counts[status.id] || 0)
        when VendorStatus.id_for(:deactivated)
          result[:deactivated] += (vendor_status_counts[status.id] || 0)
        end
      end

      result[:awaiting_approval] += self.vendors.awaiting_action_items(user).count
      result
    end
  end

  def init
  end

  def validate
  end

  def process
    if user.vendor_payments_admin?
      self.vendors = ::YesBankVendor.role_based_admin_associated_items(user, UserRole.id_for(:admin)).non_draft.or(user.vendors)
      return
    end

    if user.policy_user_roles.pluck(:user_role_id).uniq.blank?
      self.vendors = user.company.yes_bank_vendors.approved.or(user.vendors)
    else
      role_based_data = ::YesBankVendor.associated_items(user, ::YesBankVendor.roles) || ::YesBankVendor.none
      self.vendors = user.company.yes_bank_vendors.approved.or(role_based_data)
    end

  end

  def success
    params[:vendors] = self.vendors
    Vendors::Index::VendorsPresenter.new(user, params, messages)
  end
end
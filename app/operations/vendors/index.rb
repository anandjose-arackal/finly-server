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
    has_scope :filter_approved


    has_scope :sort_vendor_id
    has_scope :sort_created_at
    has_scope :sort_business_name
    has_scope :non_deleted
    has_scope :non_deleted_autocomplete

    def init
      self.vendors = params[:vendors]
      self.vendors = apply_scopes(self.vendors, params)
      self.vendors = self.vendors.sort_for_index

      page = params[:page] || 1
      per_page = params[:per_page] || 30
      self.paginated_vendors = self.vendors.paginate(page: page, per_page: per_page).include_details
      self.count = self.vendors.count
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
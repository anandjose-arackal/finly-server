

class YesBankVendor < ApplicationRecord
  include Transitionable
  include Sequenced::ActsAsSequenced

  include SoftDeletable

  acts_as_sequenced column: :vendor_id, purpose: :vendor, editable: false, prefix: 'VNDR-'

  belongs_to :company, optional: true
  belongs_to :state_code, optional: true, class_name: "GstStateCode"
  belongs_to :created_by, optional: true, class_name: "User"
  belongs_to :vendor_type, optional: true
  belongs_to :status, class_name: "VendorStatus", optional: true # todo remove optional after creation of migration

  belongs_to :currency, optional: true
  belongs_to :payment_term, optional: true

  has_many :bank_accounts, as: :account_owner, dependent: :destroy
  has_many :receiving_payments, as: :receiving_user, class_name: 'Payment'
  has_many :vendor_attachments
  has_many :custom_fields, as: :parent, dependent: :destroy
  has_many :vendor_tds_rates, dependent: :destroy, foreign_key: :vendor_id
  has_many :tds_rates, through: :vendor_tds_rates#, foreign_key: :tds_rates_list_id
  has_many :beneficiary_payments, foreign_key: :vendor_id
  has_many :gstin_locations, foreign_key: :vendor_id


  default_scope { unscope(:where) }

  # Requirement first shared by olx
  # has_one :cancelled_cheque_attachment, class_name: "VendorAttachment", dependent: :destroy
  # has_one :pan_attachment, class_name: "VendorAttachment", dependent: :destroy
  # has_one :gstin_certificate_attachment, class_name: "VendorAttachment", dependent: :destroy

  has_one :vendor_account, foreign_key: :vendor_id

  has_many :budget_criteria_mappings, as: :budgetable
  has_many :budgets, through: :budget_criteria_mappings

  has_many :budget_trails, as: :vendor


  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, to: :status

  accepts_nested_attributes_for :bank_accounts
  accepts_nested_attributes_for :vendor_attachments, allow_destroy: true
  accepts_nested_attributes_for :vendor_tds_rates, allow_destroy: true
  accepts_nested_attributes_for :gstin_locations, allow_destroy: true
  # accepts_nested_attributes_for :pan_attachment, allow_destroy: true
  # accepts_nested_attributes_for :gstin_certificate_attachment, allow_destroy: true
  # accepts_nested_attributes_for :cancelled_cheque_attachment, allow_destroy: true

  scope :with_ids, -> (ids) {where id: ids}
  scope :with_id, -> (ids) {where id: ids}

  scope :including_bank_accounts, -> {joins(:bank_accounts)}
  scope :non_deleted, -> {where deleted_at: nil}
  scope :authorized, -> { where authorized: true}
  scope :approved, -> {where status_id: [VendorStatus.id_for(:approved), VendorStatus.id_for(:auto_approved)]}

  scope :non_draft, -> {where.not(status_id: VendorStatus.id_for(:draft))}

  scope :filter_search, -> (term) do
    ids = self.pluck(:id)
    vendor_ids = where(id: ids).where("yes_bank_vendors.name like ? OR yes_bank_vendors.email like ? OR yes_bank_vendors.mobile_number like ? OR yes_bank_vendors.description like ? OR yes_bank_vendors.business_name like ?", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}", "%#{term}%").pluck(:id)
    bank_account_ids = BankAccount.where("bank_accounts.account_number like ? OR bank_accounts.ifsc like ? OR bank_accounts.name like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    vendor_ids += BankAccount.where(account_owner_type: "YesBankVendor").where(id: bank_account_ids).pluck(:account_owner_id)
    where(id: vendor_ids)
  end

  scope :filter_name_search, -> (term) {
    ids = self.pluck(:id)
    vendor_ids = where(id: ids).where("yes_bank_vendors.name like ? OR yes_bank_vendors.email like ? OR yes_bank_vendors.mobile_number like ? OR
                                      yes_bank_vendors.description like ? OR yes_bank_vendors.business_name like ? OR yes_bank_vendors.vendor_id like ?",
                                      "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:id)
    where(id: vendor_ids)
  }

  scope :sort_for_index, -> {reorder(created_at: :desc)}

  scope :filter_vendor_type_id, -> (type_id) {where vendor_type_id: type_id}
  scope :filter_status_id, -> (status_id) {where status_id: status_id}
  scope :filter_policy_id, -> (policy_id) {where policy_id: policy_id}
  scope :filter_created_by_id, -> (user_id) {where created_by_id: user_id}
  scope :filter_business_name, -> (term) {where("business_name like ?", "%#{term}%")}
  scope :filter_vendor_id, -> (vendor_id) {where(vendor_id: vendor_id)}
  scope :filter_account_details, -> (term) {
    bank_account_ids = BankAccount.where(account_owner_type: "YesBankVendor").where("bank_accounts.account_number like ? OR bank_accounts.ifsc like ? OR bank_accounts.name like ?", "%#{term}%", "%#{term}%", "%#{term}%").pluck(:account_owner_id)
    where id: bank_account_ids
  }
  scope :filter_approved, -> {
    approved
  }

  scope :includes_bank_accounts, -> {
    includes(:bank_accounts)
  }

  scope :includes_for_index, -> {
    includes(:state_code, :bank_accounts)
  }

  scope :include_details, -> {
    includes(:status, :created_by, :bank_accounts, :vendor_type, :status, :policy)
  }

  scope :includes_for_show, -> {
    includes(:status, :created_by, :bank_accounts, :vendor_type, :status, :policy, :tds_rates, gstin_locations: [:gstin_master, :location])
  }

  # Scopes for ordering
  scope :sort_vendor_id, -> (type) { ['asc', 'desc'].include?(type) ? reorder(vendor_id: type.to_sym) : reorder(vendor_id: :asc) }
  scope :sort_business_name, -> (type) { ['asc', 'desc'].include?(type) ? reorder(business_name: type.to_sym) : reorder(business_name: :asc) }
  scope :sort_created_at, -> (type) { ['asc', 'desc'].include?(type) ? reorder(created_at: type.to_sym) : reorder(created_at: :asc) }
  scope :sort_updated_at, -> (type) { ['asc', 'desc'].include?(type) ? reorder(updated_at: type.to_sym) : reorder(updated_at: :asc) }


  # Scopes for ordering ends

  after_create do
    if self.vendor_account.blank?
      self.build_vendor_account(balance_attributes: {value: 0, currency_id: 1}).save
    end
  end

  def display_name
    self.business_name.blank? ? self.name : self.business_name
  end

  def as_json(options={})
    display_name = self.business_name || self.name
    {
        id: id,
        display_name: display_name,
        vendor_id: vendor_id,
        name: name,
        created_at: created_at,
        email: email,
        mobile_number: mobile_number,
        authorized: authorized,
        description: description,
        is_deleted: is_deleted,
        pan: pan,
        tin: tin,
        gst: gst,
        gst_registered: gst_registered,
        state: state,
        state_code_id: state_code_id,
        tds_id: tds_rates_list_id,
        bank_accounts: bank_accounts
    }
  end

  def self.document_owner_attribute
    'created_by_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'VendorStatus'
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push VendorStatus.id_for(status)
    end

    status_ids.reject { |status_id| status_id.nil? }
  end

  def self.finance_associated_status_ids
    PurchaseOrderStatus.ids_for(:approved, :auto_approved)
  end

  def self.roles
    [:vendor_creator, :vendor_reviewer, :vendor_manager, :admin]
  end

  def self.role_based_associated_status_ids(user)
    self.status_ids(*self.role_based_statuses(user))
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:vendor_creator) == role_id.to_i)
          statuses += [:retracted, :rejected, :draft, :awaiting_approval, :approved, :auto_approved]
        elsif (UserRole.id_for(:vendor_reviewer) == role_id.to_i)
          statuses += [:awaiting_approval, :retracted, :rejected, :approved, :auto_approved]
        elsif UserRole.id_for(:admin) == role_id.to_i
          statuses += [:retracted, :rejected, :awaiting_approval, :approved, :auto_approved]
        end
      end
    end
    return statuses.uniq
  end

  def self.initiator_associated_items(user, role_id=nil)
    self.where(id: user.yes_bank_vendors)
  end
end

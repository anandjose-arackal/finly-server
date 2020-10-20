# == Schema Information
#
# Table name: payment_agreements
#
#  id                    :bigint           not null, primary key
#  order_number          :string(255)
#  title                 :string(255)
#  policy_id             :integer
#  agreement_date        :datetime
#  execution_date        :datetime
#  expiration_date       :datetime
#  renewal_date          :datetime
#  note                  :text(65535)
#  no_expiration         :boolean          not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  creator_id            :integer
#  controlling_level_id  :integer
#  status_id             :integer
#  submitted_at          :datetime
#  approved_at           :datetime
#  reject_note           :text(65535)
#  company_id            :integer
#  renewal_reminder_date :datetime
#  total_amount_id       :integer
#  override_order_number :string(255)
#  terminated_at         :datetime
#  terminated_by_id      :integer
#  termination_reason    :text(65535)
#  deleted_at            :datetime
#  revision_of_pa_id     :integer
#  revision_reason       :text(65535)
#  revised_by_id         :integer
#

class PaymentAgreement < ApplicationRecord

  include Transitionable, SoftDeletable
  include Sequenced::ActsAsSequenced
  # include SearchIndex::Concerns::Document
include Searchkick::Api

  event_channel 'agreements'

  acts_as_sequenced column: :order_number, purpose: :payment_agreement, editable: false, prefix: 'PA'

  belongs_to :company, optional: true
  belongs_to :status, optional: true, class_name: "PaymentAgreementStatus"
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :created_by, optional: true, class_name: "User", foreign_key: :creator_id
  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id
  belongs_to :total_amount, optional: true, class_name: 'Amount'
  belongs_to :terminated_by, optional: true, class_name: 'User'
  belongs_to :revision_of_pa, optional: true, class_name: 'PaymentAgreement'

  has_many :general_invoices, -> { where(fixed_periodic_template: [nil, false]) }, dependent: :destroy
  has_many :rental_invoices, -> { where(fixed_periodic_template: [nil, false]) }, dependent: :destroy
  has_many :fixed_periodic_general_invoices, -> { where(fixed_periodic_template: true) }, class_name: "GeneralInvoice", dependent: :destroy
  has_many :fixed_periodic_rental_invoices, -> { where(fixed_periodic_template: true) }, class_name: "RentalInvoice", dependent: :destroy
# TODO - Decommision recurring invoice, use agreement invoice instead
  has_many :recurring_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:recurring_invoice))}, class_name: 'Invoice', dependent: :destroy
  has_many :agreement_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:recurring_invoice))}, class_name: 'Invoice', dependent: :destroy

# has_many :invoices
  has_many :beneficiary_payments, dependent: :destroy
  
  has_many :notify_users, as: :document, dependent: :destroy 
  has_many :security_deposits, dependent: :destroy
  has_many :custom_fields, as: :parent, dependent: :destroy


  has_many :attachments, as: :resource, dependent: :destroy

  amoeba do
    clone [:custom_fields, :general_invoices, :rental_invoices, :beneficiary_payments, :security_deposits, :notify_users]
    exclude_association :trails
    exclude_association :recurring_invoices
    exclude_association :agreement_invoices
    exclude_association :fixed_periodic_general_invoices
    exclude_association :fixed_periodic_rental_invoices
    # exclude_association :document_level_reviewer_mappings
    exclude_association :dlrms
  end

# validates_associated :invoices
  attr_accessor :selected_invoice_frequency_attributes

  validates :title, presence: true
  validate :agreement_date_comparison, :expiration_date_if_allowed, :agreement_item_combinations


  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, :terminated?, :revised?, to: :status

  attr_accessor :payment_agreement_custom_fields

  accepts_nested_attributes_for :general_invoices, :rental_invoices, :notify_users, :attachments, :beneficiary_payments, :security_deposits, allow_destroy: true


  AGREEMENT_TYPES = [{id: 'general_invoice', name: 'Invoice - General Invoice'}, {id: 'rental_invoice', name: 'Invoice - Rental Invoice'}, {id: 'beneficiary_payment', name: 'Payment - Beneficiary Payment'}, {id: 'security_deposit', name: 'Payment - Security Deposit'}]

  scope :with_company_id, -> (company_id) { where company_id: company_id }
  scope :filter_title, -> (title) {
    if title.present?
      where('payment_agreements.title LIKE ?', "%#{title}%")
    end
  }

  scope :filter_vendor_id, -> (vendor_id){
    if vendor_id.present?
      ids = joins(:general_invoices).where('general_invoices.vendor_id = ?', vendor_id).pluck('general_invoices.payment_agreement_id')

      ids+= joins(:rental_invoices).where('rental_invoices.vendor_id = ?', vendor_id).pluck('rental_invoices.payment_agreement_id')
      ids+= joins(:beneficiary_payments).where('beneficiary_payments.vendor_id = ?', vendor_id).pluck('beneficiary_payments.payment_agreement_id')
      ids += joins(:security_deposits).where('security_deposits.vendor_id = ?', vendor_id).pluck('security_deposits.payment_agreement_id')
      where(id: ids.uniq)
    end
  }

# scope :filter_vendor_name, -> (name){
#   joins(:vendor).where('yes_bank_vendors.name = ?', "#{name}")
# }

  scope :with_ids, -> (ids) {
    where id: ids
  } 

  scope :filter_policy_id, -> (id){
    if id.present?
      where policy_id: id
    end
  }

  scope :filter_creation_date, -> (date){
    unless date.blank?
      where(created_at: date.to_date.beginning_of_day..date.to_date.end_of_day)
    end
  }

  scope :filter_invoice_due_date, ->(from, to){
    user = RequestStore.store[:current_user]
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    # ids = joins(:general_invoices).where('DATE(general_invoices.due_date) >= ? && DATE(general_invoices.due_date) <= ?', from, to).pluck(:id)
    # ids += joins(:rental_invoices).where('DATE(due_date) >= ? && DATE(due_date) <= ?', from, to).pluck(:id)
    ids = joins(:general_invoices).where('DATE(general_invoices.due_date) >= ? && DATE(general_invoices.due_date) <= ?', from, to).pluck(:id)
    ids += joins(:rental_invoices).where('DATE(rental_invoices.due_date) >= ? && DATE(rental_invoices.due_date) <= ?', from, to).pluck(:id)
    if user.present?
      user.company.payment_agreements.where(id: ids)
    end
  }

  scope :filter_creator_id, -> (id){
    if id.present?
      where creator_id: id
    end
  }

  scope :filter_status, -> (name){
    user = RequestStore.store[:current_user]
    if name.present?
      case name
      when 'processing'
        if user.present?
          # where(status_id: PaymentAgreementStatus.id_for(:awaiting_approval), creator_id: user.id)
          ids = user.payment_agreements.where(status_id: PaymentAgreementStatus.id_for(:awaiting_approval)).pluck(:id) rescue []
          with_ids(ids)
        end
      when 'awaiting_approval'
        if user.present?
          ids = self.awaiting_action_items(user.id)&.pluck(:id)
          with_ids(ids)
        end
      else
        where status_id: PaymentAgreementStatus.id_for(name.to_sym)
      end
    end
  }

  scope :filter_by_date_range, -> (from, to) {
    if from.present? || to.present?
      from = Date.parse('01-01-1990') if from.blank?
      to = Date.today if to.blank?
      from = Date.parse(from) unless from.is_a?(Date)
      to = Date.parse(to) unless to.is_a?(Date)
      where('DATE(created_at) >= ? && DATE(created_at) <= ?', from, to)
    end
  }

  scope :with_status_ids, -> (status_ids) {where status_id: status_ids}

  scope :filter_status_id, -> (status_ids) {
    with_status_ids(status_ids)
  }

  scope :filter_user_id, -> (ids) {
    where creator_id: ids
  }

  scope :filter_policy_id, -> (policy_id) {where policy_id: policy_id}

  scope :filter_location_id, -> (location_id) {where location_id: location_id}

  scope :filter_department_id, -> (ids) {
    where department_id: ids
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from created_at) = ?', year)
  }

  scope :filter_month, -> (month) {
    if month.blank?
      month = Date.today.month
    end
    where('extract(month from created_at) = ?', month)
  }

# Repitition for dashboard
  scope :filter_by_status_id,  -> (status_id) {
    if status_id == 'awaiting_approval'
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        ids = self.awaiting_action_items(RequestStore.store[:current_user]&.id)&.pluck(:id)
        with_ids(ids)
      end
    else
      where status_id: status_id
    end
  }

  scope :search_by_email, -> (email) { where creator_id: User.find_by(email: email)&.id }

  scope :not_draft, -> { where.not status_id: PaymentAgreementStatus.id_for(:draft) }

  scope :filter_awaiting_approval, -> (boolean) {
    user_id = RequestStore.store[:current_user]&.id

    if user_id.present?
      ids = self.awaiting_action_items(user_id)&.pluck(:id)
      with_ids(ids)
    end
  }

  scope :search_title, -> (search_query) {
    where('payment_agreements.title LIKE ?', "%#{search_query}%")
  }

  scope :filter_agreement_type, -> (agreement_type) {
    user = RequestStore.store[:current_user]
    ids = nil
    case agreement_type 
    when 'general_invoice'
      # joins(:invoices).where('invoices.invoice_type_id = ?', InwardInvoiceType.id_for(:general_invoice))
      ids = user.company.general_invoices.pluck(:payment_agreement_id).uniq
    when 'rental_invoice'
      # joins(:invoices).where('invoices.invoice_type_id = ?', InwardInvoiceType.id_for(:general_invoice))
      ids = user.company.rental_invoices.pluck(:payment_agreement_id).uniq
    when 'beneficiary_payment'
      # joins(:beneficiary_payments)
      ids = user.company.beneficiary_payments.pluck(:payment_agreement_id).uniq
    when 'security_deposit'
      # joins(:security_deposits)
      ids = user.company.security_deposits.pluck(:payment_agreement_id).uniq
    end

    if ids.present?
      with_ids(ids)
    end
  }

  scope :filter_invoice_number, -> (invoice_number) {
    ids = where('payment_agreements.order_number LIKE ? OR payment_agreements.override_order_number LIKE ?', "%#{invoice_number}%", "%#{invoice_number}%").pluck(:id)
    ids+= joins(:general_invoices).where('general_invoices.invoice_id LIKE ? OR general_invoices.override_invoice_id LIKE ?', "%#{invoice_number}%", "%#{invoice_number}%").pluck(:id)
    ids+= joins(:rental_invoices).where('rental_invoices.invoice_id LIKE ? OR rental_invoices.override_invoice_id LIKE ?', "%#{invoice_number}%", "%#{invoice_number}%").pluck(:id)
    with_ids(ids)
  }

  scope :exclude_revision, -> {where.not(status_id: PaymentAgreementStatus.id_for(:revised))}


  scope :include_for_index, -> {includes(:policy, :creator, :status, :security_deposits,:beneficiary_payments,:rental_invoices, :general_invoices )}

  scope :with_status_id, -> (status_id) {
    case status_id
    when 90
      # open / retracted
      where status_id: PaymentAgreementStatus.ids_for(:draft, :retracted)
    when 91
      # awaiting approval
      user_id = RequestStore.store[:current_user]&.id
      if user_id.present?
        where("#{table_name}.status_id": PaymentAgreementStatus.id_for(:awaiting_approval)).awaiting_action_items(user_id)
      else
        self.none
      end
    when 92
      where status_id: PaymentAgreementStatus.ids_for(:approved, :auto_approved, :invoice_created, :payment_ticket_created, :revised)
    else
      where(status_id: status_id)
    end
  }

  ransack_scopes :with_status_id

  def as_json(options={})
    {
        id: self.id,
        agreement_number: get_agreement_number,
        title: self.title,
        policy_id: self.policy_id,
        policy: self.policy&.name,
        created_by: self.creator&.name,
        status: self.status&.name,
        invoice_due_date: self.execution_date&.to_date,
        display_status: self.status&.name&.titleize,
        created_at: self.created_at.to_date,
        agreement_date: self.agreement_date&.to_date,
        execution_date: self.execution_date&.to_date,
        expiration_date: self.expiration_date&.to_date,
        no_expiration: self.no_expiration,
        renewal_date: self.renewal_date&.to_date,
        note: self.note,
        renewal_reminder_date: self.renewal_reminder_date,
        vendors: get_related_vendors(options),
        custom_fields: self.custom_fields,
        termination_details: {termination_reason: self.termination_reason, terminated_at: self.terminated_at&.strftime("%d-%m-%Y  %I:%M %p"), terminated_by: self.terminated_by&.name},
        revised: self.revision_of_pa_id.present?,
        revision_of_pa_id: self.revision_of_pa_id,
        revision_of_pa_order_number: self&.revision_of_pa&.get_agreement_number,
        revision_reason: self.revision_reason,
        termination_reason: self.termination_reason,
        reject_note: self.reject_note
    }
  end


  def as_json_index(options={})
    {
        id: self.id,
        agreement_number: get_agreement_number,
        title: self.title,
        policy_id: self.policy_id,
        policy: self.policy&.name,
        created_by: self.creator&.name,
        status: self.status&.name,
        vendors: get_related_vendors(options)
    }
  end

  def self.document_owner_attribute
    'creator_id'
  end

  def self.document_status_attribute
    'status_id'
  end

  def self.document_status_class_name
    'PaymentAgreementStatus'
  end

  def self.roles
    [:admin, :payment_agreement_initiator, :payment_agreement_reviewer, :payment_agreement_auditor, :agreement_invoice_initiator, :agreement_invoice_reviewer, :agreement_invoice_auditor]
  end

  def self.agreement_master_roles
    [:admin, :payment_agreement_initiator, :payment_agreement_reviewer, :payment_agreement_auditor]
  end

  def get_default_provider
    'PaymentAgreementProvider'
  end

  def self.status_ids(*statuses)
    status_ids = []
    statuses.each do |status|
      status_ids.push PaymentAgreementStatus.id_for(status)
    end
    return status_ids.flatten.compact
  end

# For user role as payment agreement initiator
  def is_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:payment_agreement_initiator), self)
  end

# For user role as payment agreement reviewer
  def is_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:payment_agreement_reviewer), self)
  end

  def self.open_status_ids(user)
    PaymentAgreementStatus.ids_for([:open, :draft])
  end

  def self.role_based_associated_status_ids(user)
    PaymentAgreementStatus.ids_for(self.role_based_statuses(user))
  end

  def self.auditor_associated_status_ids
    self.status_ids(:awaiting_approval, :approved, :auto_approved, :retracted, :rejected, :closed)
  end

  def self.role_based_statuses(user)
    statuses = []
    if user.policy_user_roles.pluck(:user_role_id).uniq.present?
      user.policy_user_roles.pluck(:user_role_id).uniq.each do |role_id|
        if (UserRole.id_for(:payment_agreement_initiator) == role_id.to_i)
          statuses += [:draft, :retracted, :awaiting_approval, :approved, :rejected, :auto_approved]
        elsif (UserRole.id_for(:payment_agreement_reviewer) == role_id.to_i)
          statuses += [:awaiting_approval, :approved, :auto_approved]
        end
      end
    end
    return statuses.uniq
  end

  def agreement_date_comparison
    validate_agreement_date
    validate_execution_date
    validate_comparison_between_dates
  end

  def validate_agreement_date
    if self.agreement_date.blank?
      errors.add(:agreement_date, 'cannot be blank')
    end
  end

  def validate_execution_date
    if self.execution_date.blank?
      errors.add(:execution_date, 'cannot be blank')
    end
  end

  def validate_comparison_between_dates
    validate_comparison_with_execution_date
    validate_renewal_reminder
  end

  def validate_comparison_with_execution_date
    if self.agreement_date.present? && self.execution_date.present?
      # Payment agreement cannot be created for past months
      # validate_current_month
      if self.agreement_date > self.execution_date
        errors.add(:agreement_date, 'cannot be greater than execution date')
      end
    end
  end

  def validate_current_month
    if self.agreement_date.present?
      if self.agreement_date&.to_date < Date.today.beginning_of_month
        errors.add(:agreement_date, 'cannot be from previous months')
      end
    end

    if self.execution_date.present?
      if self.execution_date&.to_date < Date.today.beginning_of_month
        errors.add(:execution_date, 'cannot be from previous months')
      end
    end
  end

  def self.awaiting_records user
    # awaiting approval
    user_id = user&.id
    if user_id.present?
      where("#{table_name}.status_id": PaymentAgreementStatus.id_for(:awaiting_approval)).awaiting_action_items(user_id)
    else
      self.none
    end
  end

  def expiration_date_if_allowed
    if self.no_expiration.blank? && self.expiration_date.blank?
      errors.add(:expiration_date, ' cannot be blank or agreement should never expire')
    end
    if self.no_expiration.present? && self.expiration_date.present?
      errors.add(:expiration_date, ' and never expire cannot exist at the same time')
    end
    if self.no_expiration.blank? && self.expiration_date.present?
      if self.expiration_date < self.execution_date
        errors.add(:expiration_date, ' cannot be smaller than execution date')
      end
    end

  end

  def validate_renewal_reminder
    unless self.no_expiration 
      if self.execution_date.present? && self.expiration_date.present? && self.renewal_reminder_date.present?
        if (self.renewal_reminder_date < self.execution_date) || (self.renewal_reminder_date > self.expiration_date)
          errors.add(:renewal_reminder_date, ' should be between execution and expiry date')
        end
      end 
    end
  end

  def validate_if_auditor(user)
    if self.policy.present? && self.policy.policy_user_roles.present?
      self.policy.policy_user_roles.where(user_role_id: UserRole.id_for(:payment_agreement_auditor), user_id: user.id).present? rescue false
    end
  end

  def get_related_vendors(options)
    vendors = []
    if options[:list_vendors]
      vendors << self.general_invoices.joins(:vendor).pluck('yes_bank_vendors.business_name') rescue []
      vendors << self.rental_invoices.joins(:vendor).pluck('yes_bank_vendors.business_name') rescue []
      vendors << self.security_deposits.joins(:vendor).pluck('yes_bank_vendors.business_name') rescue [] if self.rental_invoices.blank?
      vendors << self.beneficiary_payments.joins(:vendor).pluck('yes_bank_vendors.business_name') rescue []
    end
    return vendors.flatten.compact
  end

  def agreement_item_combinations
    if self.general_invoices.reject(&:marked_for_destruction?).present? && self.rental_invoices.reject(&:marked_for_destruction?).present?
      errors.add(:general_invoices, ' and rental invoices cannot be present at the same time')
    end
    if self.general_invoices.reject(&:marked_for_destruction?).present? && self.beneficiary_payments.reject(&:marked_for_destruction?).present?
      errors.add(:general_invoices, ' and beneficiary payment cannot be present at the same time')
    end
  end

  def get_agreement_number
    self.override_order_number.present? ? self.override_order_number : self.order_number
  end

  def is_agreement_invoice_initiating_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_initiator), self)
  end

  def is_agreement_invoice_reviewing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_reviewer), self)
  end

  def is_agreement_invoice_auditing_user?(user = nil)
    user = user.present? ? user : RequestStore.store[:current_user]
    user.has_policy_role?(UserRole.id_for(:agreement_invoice_auditor), self)
  end

  def get_custom_fields(options)
    #default return custom fields but index not needed custom fields
    if options[:load_custom_fields].nil?
      self.custom_fields
    elsif options[:load_custom_fields].present? && options[:load_custom_fields] == true
      self.custom_fields
    elsif options[:load_custom_fields] && options[:load_custom_fields] == false
      nil
    end
  end

# Used for tracking completion %
  def review_pending?
    PaymentAgreementStatus.ids_for(:draft, :retracted, :rejected).include?(status_id)
  end

  def review_completed?
    PaymentAgreementStatus.ids_for(:approved, :auto_approved, :closed, :invoice_created, :payment_ticket_created, :terminated, :revised).include?(status_id)
  end

  def review_in_progress?
    PaymentAgreementStatus.ids_for(:awaiting_approval).include?(status_id)
  end

end

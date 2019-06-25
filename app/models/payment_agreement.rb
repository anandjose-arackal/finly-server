class PaymentAgreement < ApplicationRecord

  include Transitionable

  belongs_to :company, optional: true
  belongs_to :status, optional: true, class_name: "PaymentAgreementStatus"
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id


  has_many :general_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:general_invoice))}, class_name: 'Invoice', dependent: :destroy
  has_many :rental_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:rental_invoice))}, class_name: 'Invoice', dependent: :destroy
  has_many :invoices
  has_many :beneficiary_payments, dependent: :destroy
  
  has_many :notify_users, as: :document, dependent: :destroy 
  has_many :security_deposits, dependent: :destroy


  has_many :attachments, as: :resource, dependent: :destroy

  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, to: :status

  accepts_nested_attributes_for :general_invoices, :rental_invoices, :notify_users, :attachments, :beneficiary_payments, :security_deposits, allow_destroy: true


  AGREEMENT_TYPES = [{id: 'general_invoice', name: 'Invoice - General Invoice'}, {id: 'rental_invoice', name: 'Invoice - Rental Invoice'}, {id: 'beneficiary_payment', name: 'Payment - Beneficiary Payment'}, {id: 'security_deposit', name: 'Payment - Security Deposit'}]

  scope :filter_title, -> (title) {
    where title: "#{title}"
  }

  scope :filter_vendor_id, -> (vendor_id){
    ids = joins(:general_invoices).where('invoices.vendor_id = ?', vendor_id).pluck(:payment_agreement_id)

    ids+= joins(:rental_invoices).where('invoices.vendor_id = ?', vendor_id).pluck(:payment_agreement_id)
    ids+= joins(:beneficiary_payments).where('beneficiary_payments.vendor_id = ?', vendor_id).pluck(:payment_agreement_id)
    where(id: ids)
  }

  # scope :filter_vendor_name, -> (name){
  #   joins(:vendor).where('yes_bank_vendors.name = ?', "#{name}")
  # }

  scope :filter_policy_id, -> (id){
    where policy_id: id
  }

  scope :filter_creation_date, -> (date){
    unless date.blank?
      where(created_at: date.to_date.beginning_of_day..date.to_date.end_of_day)
    end
  }

  scope :filter_invoice_due_date, ->(from, to){
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    joins(:invoices).where('DATE(due_date) >= ? && DATE(due_date) <= ?', from, to)
  }

  scope :filter_creator_id, -> (id){
    where creator_id: id
  }

  scope :filter_status_id, -> (id){
    where status_id: id
  }

  scope :filter_status, -> (name){
    if name.present?
      where status_id: PaymentAgreementStatus.id_for(name.to_sym)
    end
  }


  def as_json
    {
      id: self.id,
      agreement_number: self.order_number,
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
      renewal_reminder_date: self.renewal_reminder_date
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

end

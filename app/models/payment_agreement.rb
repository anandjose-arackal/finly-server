class PaymentAgreement < ApplicationRecord

  include Transitionable

  belongs_to :company, optional: true
  belongs_to :status, optional: true, class_name: "PaymentAgreementStatus"
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id


  has_many :general_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:general_invoice))}, class_name: 'Invoice', dependent: :destroy
  has_many :rental_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:rental_invoice))}, class_name: 'Invoice', dependent: :destroy

  has_many :beneficiary_payments, dependent: :destroy
  has_many :notify_users, as: :document, dependent: :destroy 
  has_many :security_deposits, dependent: :destroy


  has_many :attachments, as: :resource, dependent: :destroy

  delegate :draft?, :retracted?, :rejected?, :awaiting_approval?, :approved?, :auto_approved?, :closed?, to: :status

  accepts_nested_attributes_for :general_invoices, :rental_invoices, :notify_users, :attachments, :beneficiary_payments, :security_deposits, allow_destroy: true


  AGREEMENT_TYPES = [{general_invoice: 'Invoice - General Invoice'}, {rental_invoice: 'Invoice - Rental Invoice'}, {beneficiary_payment: 'Payment - Beneficiary Payment'}, {security_deposit: 'Payment - Security Deposit'}]

  scope :filter_title, -> (title) {
    where title: "#{title}"
  }

  scope :filter_vendor_id, -> (id){
    where vendor_id: id
  }

  scope :filter_vendor_name, -> (name){
    joins(:vendor).where('yes_bank_vendors.name = ?', "#{name}")
  }

  scope :filter_policy_id, -> (id){
    where policy_id: id
  }

  scope :filter_creation_date, -> (from, to){
    from = Date.parse('01-01-1990') if from.blank?
    to = Date.today if to.blank?
    from = Date.parse(from) unless from.is_a?(Date)
    to = Date.parse(to) unless to.is_a?(Date)
    where('DATE(created_at) >= ? && DATE(created_at) <= ?', from, to)
  }

  scope :filter_creator_id, -> (id){
    where creator_id: id
  }

  scope :filter_status_id, -> (id){
    where status_id: id
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

  def self.document_status_attribute
    'status_id'
  end

  def self.roles
    [:admin, :payment_agreement_initiator, :payment_agreement_reviewer, :payment_agreement_auditor]
  end

  def get_default_provider
    'PaymentAgreementProvider'
  end
end

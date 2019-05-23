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

  accepts_nested_attributes_for :general_invoices, :rental_invoices, :notify_users, :attachments, :beneficiary_payments, :security_deposits, allow_destroy: true


  AGREEMENT_TYPES = [{general_invoice: 'Invoice - General Invoice'}, {rental_invoice: 'Invoice - Rental Invoice'}, {beneficiary_payment: 'Payment - Beneficiary Payment'}, {security_deposit: 'Payment - Security Deposit'}]

  def as_json
    {
      id: self.id,
      agreement_number: self.order_number,
      title: self.title,
      policy: self.policy&.name,
      created_by: self.creator&.name,
      status: self.status&.name,
      invoice_due_date: self.execution_date&.to_date,
      display_status: self.status&.name&.titleize,
      created_at: self.created_at.to_date,
      agreement_date: self.agreement_date&.to_date,
      execution_date: self.execution_date&.to_date,
      expiry_date: self.expiry_date&.to_date,
      no_expiration: self.no_expiration,
      renewal_date: self.renewal_date&.to_date,
      note: self.note
    }
  end

  def self.document_status_attribute
    'status_id'
  end
end

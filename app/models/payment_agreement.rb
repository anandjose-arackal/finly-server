class PaymentAgreement < ApplicationRecord

  include Transitionable

  belongs_to :company, optional: true
  belongs_to :status, optional: true, class_name: "PaymentAgreementStatus"
  belongs_to :creator, optional: true, class_name: 'User'
  belongs_to :policy, optional: true
  belongs_to :level, optional: true, class_name: 'ReviewalLevel', foreign_key: :controlling_level_id


  has_many :general_invoices, -> { joins(:invoice_type).where('inward_invoice_types.id = ?', InwardInvoiceType.id_for(:general_invoice))}, class_name: 'Invoice', dependent: :destroy

  has_many :attachments, as: :resource, dependent: :destroy

  accepts_nested_attributes_for :general_invoices, :attachments, allow_destroy: true


  def as_json
    {
      id: self.id,
      title: self.title,
      policy: self.policy.name,
      creator: self.creator.name,
      status: self.status.name,
      invoice_due_date: self.execution_date.to_date
    }
  end

end

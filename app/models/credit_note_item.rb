class CreditNoteItem < ApplicationRecord
  include MathUtil

  belongs_to :credit_note, optional: true
  belongs_to :invoice_item, class_name: 'InvoiceLineItem', optional: true
  belongs_to :item, class_name: 'Item', optional: true


  belongs_to :procurement, optional: true
  belongs_to :vendor, class_name: 'YesBankVendor', optional: true
  belongs_to :shipping_location, class_name: 'BranchLocation', optional: true
  belongs_to :billing_location, class_name: 'BranchLocation', optional: true

  belongs_to :gross_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :gst_amount, class_name: 'Amount', optional: true
  belongs_to :discount_amount, class_name: 'Amount', optional: true
  belongs_to :net_receivable_amount, class_name: 'Amount', optional: true
  belongs_to :tds_amount, class_name: 'Amount', optional: true
  belongs_to :freight_amount, class_name: 'Amount', optional: true
  belongs_to :previously_adjusted_amount, class_name: 'Amount', optional: true
  belongs_to :net_adjustable_amount, class_name: 'Amount', optional: true

  belongs_to :tds_rate_id, class_name: 'TdsRatesList', optional: true


  delegate :draft?, :awaiting_approval?, :retracted?, :rejected?, :approved?, :auto_approved?, :voided?, :adjusted?, :partially_adjusted?, to: :status
end

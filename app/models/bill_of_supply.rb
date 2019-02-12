# == Schema Information
#
# Table name: bill_of_supplies
#
#  id                     :integer          not null, primary key
#  company_id             :integer
#  user_id                :integer
#  procurement_id         :integer
#  location_id            :integer
#  delivery_location_id   :integer
#  vendor_id              :integer
#  payment_term_id        :integer
#  procurement_term_id    :integer
#  document_status_id     :integer
#  doc_number             :string(255)
#  override_doc_number    :boolean
#  prefix                 :string(255)
#  sequence_start         :string(255)
#  date                   :date
#  bill_date              :date
#  transaction_date       :date
#  due_date               :date
#  roundoff_total_enabled :boolean
#  roundoff_amount        :decimal(10, 5)
#  transaction_amount_id  :integer
#  total_before_tax_id    :integer
#  tax_amount_id          :integer
#  total_after_tax_id     :integer
#  discount_amount_id     :integer
#  balance_amount_id      :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  is_deleted             :boolean          default(FALSE), not null
#  deleted_at             :datetime
#

class BillOfSupply < ApplicationRecord
  include SoftDeletable
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :procurement, optional: true
  belongs_to :location, optional: true
  belongs_to :payment_term, optional: true
  belongs_to :procurement_term, optional: true
  belongs_to :document_status, optional: true

  belongs_to :vendor, optional: true, class_name: "YesBankVendor"

  belongs_to :tax_amount, optional: true, class_name: "Amount"
  belongs_to :discount_amount, optional: true, class_name: "Amount"
  belongs_to :balance_amount, optional: true, class_name: "Amount"

  has_many :items, class_name: "DocumentItem", as: :parent_document
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document

  accepts_nested_attributes_for :items
end

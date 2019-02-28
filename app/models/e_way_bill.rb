# == Schema Information
#
# Table name: e_way_bills
#
#  id                        :integer          not null, primary key
#  company_id                :integer
#  user_id                   :integer
#  procurement_id            :integer
#  location_id               :integer
#  delivery_location_id      :integer
#  vendor_id                 :integer
#  payment_term_id           :integer
#  procurement_term_id       :integer
#  doc_number                :string(255)
#  date                      :date
#  generated_by              :string(255)
#  valid_from                :datetime
#  valid_to                  :datetime
#  ref_doc_name              :string(255)
#  ref_doc_date              :string(255)
#  amount_id                 :integer
#  hsn_code                  :string(255)
#  reason_for_transportation :string(255)
#  mode                      :string(255)
#  vehicle_number            :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  is_deleted                :boolean          default(FALSE), not null
#  deleted_at                :datetime
#

class EWayBill < ApplicationRecord
  include SoftDeletable
  belongs_to :company, optional: true
  belongs_to :user, optional: true
  belongs_to :procurement, optional: true
  belongs_to :amount, optional: true

  belongs_to :vendor, optional: true, class_name: 'YesBankVendor'

  has_many :items, class_name: "DocumentItem", as: :parent_document
  has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document
  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable

  accepts_nested_attributes_for :items
end

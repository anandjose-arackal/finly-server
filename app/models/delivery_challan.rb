# == Schema Information
#
# Table name: delivery_challans
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
#  challan_date           :date
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

class DeliveryChallan < ActiveRecord::Base
  include SoftDeletable
  belongs_to :company
  belongs_to :user
  belongs_to :procurement
  belongs_to :location
  belongs_to :payment_term
  belongs_to :procurement_term
  belongs_to :document_status


  has_many :comments, class_name: 'ProcurementComment', as: :parent_commentable
end

# == Schema Information
#
# Table name: outward_invoice_trails
#
#  id                          :integer          not null, primary key
#  action_id                   :integer
#  outward_invoice_id          :integer
#  user_id                     :integer
#  note                        :string(255)
#  amount_id                   :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  associated_entity_id        :integer
#  associated_entity_type      :string(255)
#  associated_transaction_id   :integer
#  associated_transaction_type :string(255)
#  date                        :date
#

class OutwardInvoiceTrail < ApplicationRecord
  belongs_to :customer_account_transaction, optional: true
  belongs_to :user, optional: true
  belongs_to :amount, optional: true
  belongs_to :invoice, optional: true, class_name: 'OutwardInvoice'
  belongs_to :action, optional: true, class_name: 'OutwardInvoiceTrailAction'

  belongs_to :associated_entity, optional: true, polymorphic: true
  belongs_to :associated_transaction, optional: true, polymorphic: true

  accepts_nested_attributes_for :amount

  default_scope { order(created_at: :desc) }
end

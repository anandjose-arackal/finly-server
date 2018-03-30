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
#

class OutwardInvoiceTrail < ActiveRecord::Base
  belongs_to :customer_account_transaction
  belongs_to :user
  belongs_to :amount
  belongs_to :invoice, class_name: 'OutwardInvoice'
  belongs_to :action, class_name: 'OutwardInvoiceTrailAction'

  belongs_to :associated_entity, polymorphic: true
  belongs_to :associated_transaction, polymorphic: true

  accepts_nested_attributes_for :amount
end

# == Schema Information
#
# Table name: customer_account_transactions
#
#  id                     :integer          not null, primary key
#  customer_account_id    :integer
#  transaction_type       :string(255)
#  transaction_amount_id  :integer
#  note                   :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  associated_object_id   :integer
#  associated_object_type :string(255)
#

# Transaction type: credit, debit

class CustomerAccountTransaction < ApplicationRecord
  belongs_to :customer_account, optional: true
  belongs_to :virtual_account_transaction, optional: true
  belongs_to :associated_object, optional: true, polymorphic: true
  belongs_to :transaction_amount, optional: true, class_name: 'Amount'

  has_one :outward_invoice_trail, as: :associated_transaction

  accepts_nested_attributes_for :transaction_amount

  default_scope { order(created_at: :desc) }
end

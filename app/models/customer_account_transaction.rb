# == Schema Information
#
# Table name: customer_account_transactions
#
#  id                             :integer          not null, primary key
#  customer_account_id            :integer
#  transaction_type               :string(255)
#  virtual_account_transaction_id :integer
#  transaction_amount_id          :integer
#  note                           :string(255)
#  created_at                     :datetime         not null
#  updated_at                     :datetime         not null
#


# Transaction type: credit, debit

#todo associated_object_id

class CustomerAccountTransaction < ActiveRecord::Base
  belongs_to :customer_account
  belongs_to :virtual_account_transaction
  belongs_to :transaction_amount, class_name: 'Amount'
end

# == Schema Information
#
# Table name: customer_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  balance_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :datetime
#

class CustomerAccount < ApplicationRecord
  belongs_to :customer, optional: true
  belongs_to :balance, optional: true, class_name: 'Amount'

  has_many :customer_account_transactions


  accepts_nested_attributes_for :balance
end

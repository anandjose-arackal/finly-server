# == Schema Information
#
# Table name: customer_accounts
#
#  id          :integer          not null, primary key
#  customer_id :integer
#  balance_id  :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CustomerAccount < ActiveRecord::Base
  belongs_to :customer
  belongs_to :balance, class_name: 'Amount'

  has_many :customer_account_transactions


  accepts_nested_attributes_for :balance
end

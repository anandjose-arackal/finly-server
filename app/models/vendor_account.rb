# == Schema Information
#
# Table name: vendor_accounts
#
#  id         :integer          not null, primary key
#  balance_id :integer
#  vendor_id  :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class VendorAccount < ApplicationRecord

  belongs_to :balance, optional: true, class_name: "Amount"
  belongs_to :vendor, optional: true, class_name: "YesBankVendor"

  has_many :finly_transactions, as: :finly_account

  accepts_nested_attributes_for :balance
end
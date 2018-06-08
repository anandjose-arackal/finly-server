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

class VendorAccount < ActiveRecord::Base

  belongs_to :balance, class_name: "Amount"
  belongs_to :vendor, class_name: "YesBankVendor"

  accepts_nested_attributes_for :balance
end
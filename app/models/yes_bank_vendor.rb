# == Schema Information
#
# Table name: yes_bank_vendors
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  company_id    :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  email         :string(255)
#  mobile_number :string(255)
#

class YesBankVendor < ActiveRecord::Base
  belongs_to :company

  has_many :bank_accounts, as: :account_owner, dependent: :destroy
  has_many :receiving_payments, as: :receiving_user
end

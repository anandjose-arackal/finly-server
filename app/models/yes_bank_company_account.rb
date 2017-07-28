# == Schema Information
#
# Table name: yes_bank_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  balance_id        :integer
#

class YesBankCompanyAccount < ActiveRecord::Base
  belongs_to :company
  belongs_to :balance, class_name: "Amount"

  delegate :balance_value, to: :balance
end

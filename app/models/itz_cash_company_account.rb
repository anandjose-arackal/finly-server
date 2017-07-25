# == Schema Information
#
# Table name: itz_cash_company_accounts
#
#  id                :integer          not null, primary key
#  company_id        :integer
#  wallet_balance_id :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class ItzCashCompanyAccount < ActiveRecord::Base
  belongs_to :company
end

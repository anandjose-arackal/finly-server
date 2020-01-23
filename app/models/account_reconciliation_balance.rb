# == Schema Information
#
# Table name: account_reconciliation_balances
#
#  id                        :bigint           not null, primary key
#  reconciliation_balance_id :integer
#  account_id                :integer
#  account_type              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  uuid                      :string(36)
#

class AccountReconciliationBalance < ApplicationRecord
end

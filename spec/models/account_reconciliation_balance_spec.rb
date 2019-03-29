# == Schema Information
#
# Table name: account_reconciliation_balances
#
#  id                        :bigint(8)        not null, primary key
#  reconciliation_balance_id :integer
#  account_id                :integer
#  account_type              :integer
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'rails_helper'

RSpec.describe AccountReconciliationBalance, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

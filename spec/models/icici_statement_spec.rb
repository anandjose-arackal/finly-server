# == Schema Information
#
# Table name: icici_statements
#
#  id                  :bigint           not null, primary key
#  cheque_no           :string(255)
#  txn_date            :datetime
#  amount              :decimal(10, 5)
#  balance             :decimal(10, 5)
#  value_date          :datetime
#  type                :string(255)
#  transaction_id      :string(255)
#  request_id          :string(255)
#  bank_transaction_id :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'rails_helper'

RSpec.describe IciciStatement, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

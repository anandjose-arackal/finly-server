# == Schema Information
#
# Table name: icici_bank_transactions
#
#  id                    :bigint(8)        not null, primary key
#  aggr_id               :string(255)
#  aggr_name             :string(255)
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corp_id               :string(255)
#  user_id               :string(255)
#  debit_acc             :string(255)
#  credit_acc            :string(255)
#  txn_type              :string(255)
#  amount_id             :integer
#  ifsc                  :string(255)
#  receiving_account_id  :integer
#  otp                   :string(255)
#  payee_name            :text(65535)
#  remarks               :text(65535)
#  customer_induced      :boolean
#  transfer_type         :string(255)
#  unique_request_number :string(255)
#  utr                   :string(255)
#  transfer_status_id    :integer
#  company_id            :integer
#

require 'rails_helper'

RSpec.describe IciciBankTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

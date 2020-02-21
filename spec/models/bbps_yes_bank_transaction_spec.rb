# == Schema Information
#
# Table name: bbps_yes_bank_transactions
#
#  id                   :bigint           not null, primary key
#  message_code         :string(255)
#  status               :string(255)
#  error_code           :string(255)
#  error_desc           :string(255)
#  order_number         :string(255)
#  agent_institution_id :string(255)
#  channel_id           :string(255)
#  bbps_ref_id          :string(255)
#  agent_id             :string(255)
#  customer_name        :string(255)
#  customer_mobile      :string(255)
#  customer_email       :string(255)
#  customer_aadhar_no   :string(255)
#  customer_pan_id      :string(255)
#  biller_id            :string(255)
#  amount               :string(255)
#  bill_date            :string(255)
#  due_date             :string(255)
#  bill_number          :string(255)
#  bill_period          :string(255)
#  convenience_fee      :string(255)
#  convenience_fee_desc :string(255)
#  late_payment_fee     :string(255)
#  early_payment_fee    :string(255)
#  additional_field     :string(255)
#  bill_id              :integer
#  company_id           :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  transfer_status_id   :integer
#  amount_id            :integer
#  quick_pay            :string(255)      default("N")
#  reference_payment_id :integer
#  deleted_at           :datetime
#

require 'rails_helper'

RSpec.describe BbpsYesBankTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

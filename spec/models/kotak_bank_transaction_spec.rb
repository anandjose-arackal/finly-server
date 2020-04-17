# == Schema Information
#
# Table name: kotak_bank_transactions
#
#  id                         :bigint           not null, primary key
#  amount_id                  :integer
#  company_id                 :integer
#  transfer_status_id         :integer
#  beneficiary_account_id     :integer
#  utr                        :string(255)
#  response_status_code       :string(255)
#  unique_reference_number    :string(255)
#  transfer_type              :string(255)
#  beneficiary_account_number :string(255)
#  beneficiary_account_ifsc   :string(255)
#  beneficiary_name           :string(255)
#  narration                  :string(255)
#  payment_date               :date
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  bank_response              :text(65535)
#  reversal_status_code       :string(255)
#  reversal_response          :text(65535)
#  reversal_api_counter       :integer          default(0)
#  deleted_at                 :datetime
#  reference_payment_id       :integer
#  bank_error_message         :text(16777215)
#  transfer_mode_id           :integer
#

require 'rails_helper'

RSpec.describe KotakBankTransaction, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

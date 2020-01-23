# == Schema Information
#
# Table name: security_deposits
#
#  id                              :bigint           not null, primary key
#  vendor_id                       :integer
#  vendor_location_id              :integer
#  cost_center_id                  :integer
#  department_id                   :integer
#  location_id                     :integer
#  note                            :text(65535)
#  description                     :text(65535)
#  payable_amount_id               :integer
#  original_amount_id              :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  payment_agreement_id            :integer
#  bank_account_id                 :integer
#  company_id                      :integer
#  creator_id                      :integer
#  payment_agreement_upcoming_date :date
#  status_id                       :integer
#  uuid                            :string(36)
#

require 'rails_helper'

RSpec.describe SecurityDeposit, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

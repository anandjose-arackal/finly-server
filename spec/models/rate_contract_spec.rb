# == Schema Information
#
# Table name: rate_contracts
#
#  id                      :bigint(8)        not null, primary key
#  name                    :string(255)
#  vendor_id               :integer
#  renewable               :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  item_id                 :integer
#  creator_id              :integer
#  renewal_alert_number    :integer
#  renewal_alert_period_id :integer
#  note                    :string(255)
#  company_id              :integer
#  rate_contract_number    :string(255)
#

require 'rails_helper'

RSpec.describe RateContract, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

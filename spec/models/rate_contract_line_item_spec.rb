# == Schema Information
#
# Table name: rate_contract_line_items
#
#  id               :bigint(8)        not null, primary key
#  location_id      :integer
#  item_id          :integer
#  start_date       :datetime
#  end_date         :datetime
#  rate_contract_id :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  amount_id        :integer
#

require 'rails_helper'

RSpec.describe RateContractLineItem, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

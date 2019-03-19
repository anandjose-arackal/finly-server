# == Schema Information
#
# Table name: vendor_tds_rates
#
#  id                :bigint(8)        not null, primary key
#  vendor_id         :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  tds_rates_list_id :integer
#

require 'rails_helper'

RSpec.describe VendorTdsRate, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

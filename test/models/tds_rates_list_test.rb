# == Schema Information
#
# Table name: tds_rates_lists
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  tds        :decimal(10, 5)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  company_id :integer
#

require 'test_helper'

class TdsRatesListTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

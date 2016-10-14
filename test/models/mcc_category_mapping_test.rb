# == Schema Information
#
# Table name: mcc_category_mappings
#
#  id          :integer          not null, primary key
#  category_id :integer
#  mcc_code    :string(255)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class MccCategoryMappingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

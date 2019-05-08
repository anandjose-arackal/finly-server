# == Schema Information
#
# Table name: cost_centers
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  application      :string(255)
#  company_id       :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  is_deleted       :boolean
#  deleted_at       :datetime
#  cost_center_code :string(255)
#

require 'test_helper'

class CostCenterTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

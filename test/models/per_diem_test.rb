# == Schema Information
#
# Table name: per_diems
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  rate_id    :integer
#  company_id :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class PerDiemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

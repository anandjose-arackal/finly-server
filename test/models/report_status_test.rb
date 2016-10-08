# == Schema Information
#
# Table name: report_statuses
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  order      :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#


require 'test_helper'

class ReportStatusTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

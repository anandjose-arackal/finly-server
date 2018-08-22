# == Schema Information
#
# Table name: procurement_status_taggables
#
#  id             :integer          not null, primary key
#  procurement_id :integer
#  status_tag_id  :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

require 'test_helper'

class ProcurementStatusTaggableTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: card_assign_requests
#
#  id                        :integer          not null, primary key
#  card_id                   :integer
#  card_owner_id             :integer          not null
#  initiating_resource_id    :integer          not null
#  initiating_resource_type  :string(255)      not null
#  status_id                 :integer          not null
#  assigned_by_resource_id   :integer
#  assigned_by_resource_type :string(255)
#  assigned_on               :datetime
#  card_program_id           :integer          not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  admin_review_workflow_id  :integer
#  review_position           :integer          default(0)
#

require 'test_helper'

class CardAssignRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

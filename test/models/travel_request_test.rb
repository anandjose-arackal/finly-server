# == Schema Information
#
# Table name: travel_requests
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  policy_id                    :integer
#  name                         :string(255)
#  note                         :text(65535)
#  status_id                    :integer          not null
#  controlling_user_id          :integer
#  controlling_user_role_id     :integer
#  controlling_for_user_id      :integer
#  controlling_for_user_role_id :integer
#  submitted_at                 :datetime
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  company_id                   :integer
#  is_deleted                   :boolean          default(FALSE)
#  rejection_note               :text(65535)
#  auto_approved                :boolean
#  memo                         :text(65535)
#  from_date                    :date
#  to_date                      :date
#

require 'test_helper'

class TravelRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

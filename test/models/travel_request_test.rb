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
#  trip_id                      :string(255)
#  purpose_of_travel            :text(65535)
#  approved_at                  :datetime
#  selection_requested_at       :datetime
#  booking_confirmed_at         :datetime
#  controlling_level_id         :integer
#

require 'test_helper'

class TravelRequestTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

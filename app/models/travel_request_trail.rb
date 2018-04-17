# == Schema Information
#
# Table name: travel_request_trails
#
#  id                      :integer          not null, primary key
#  travel_request_id       :integer
#  action_id               :integer
#  action_user_id          :integer
#  action_user_role_id     :integer
#  modified_user_id        :integer
#  modified_user_role_id   :integer
#  action_for_user_id      :integer
#  action_for_user_role_id :integer
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class TravelRequestTrail < ActiveRecord::Base
  belongs_to :travel_request
  belongs_to :action_id, class_name: "TravelRequestTrailAction"
  belongs_to :action_user, class_name: "User"
  belongs_to :modified_user, class_name: "User"
  belongs_to :action_for_user, class_name: "User"

  belongs_to :action_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"
  belongs_to :modified_user_role, class_name: "UserRole"
  
end

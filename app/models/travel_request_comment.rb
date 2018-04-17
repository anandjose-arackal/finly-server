# == Schema Information
#
# Table name: travel_request_comments
#
#  id                :integer          not null, primary key
#  travel_request_id :integer
#  content           :text(65535)
#  user_id           :integer
#  note              :text(65535)
#  previous_value    :text(65535)
#  new_value         :text(65535)
#  edited_field      :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  action_id         :integer
#

class TravelRequestComment < ActiveRecord::Base
  belongs_to :travel_request
  belongs_to :user
  belongs_to :action, class_name: "TravelRequestCommentAction"
end

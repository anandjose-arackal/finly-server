# == Schema Information
#
# Table name: card_load_request_tracks
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  controlling_user_id  :integer
#  status_id            :integer
#  received_from_id     :integer
#  forwarding_to_id     :integer
#  previous_tracking_id :integer
#  next_tracking_id     :integer
#  request_id           :integer
#  memo                 :text(65535)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  action_id            :integer
#

class CardLoadRequestTrack < ActiveRecord::Base

  belongs_to :user
  belongs_to :controlling_user, class_name: "User"
  belongs_to :status, class_name: "CardRequestStatus"
  belongs_to :received_from, class_name: "User"
  belongs_to :forwarding_to, class_name: "User"
  belongs_to :request_id, class_name: "CardLoadRequest"
  belongs_to :action, class_name: "CardLoadRequestAction"

end

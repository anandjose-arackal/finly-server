# == Schema Information
#
# Table name: card_assign_request_tracks
#
#  id                     :integer          not null, primary key
#  card_assign_request_id :integer          not null
#  action_resource_id     :integer
#  action_resource_type   :string(255)
#  action_id              :integer          not null
#  note                   :text(65535)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class CardAssignRequestTrack < ActiveRecord::Base
  belongs_to :card_assign_request
  belongs_to :action_resource, polymorphic: true
  belongs_to :action, class_name: 'CardAssignRequestTrackAction'

end

# == Schema Information
#
# Table name: user_session_events
#
#  id                        :integer          not null, primary key
#  user_session_id           :integer          not null
#  http_method               :string(255)
#  app                       :string(255)
#  path                      :string(255)
#  controller                :string(255)      not null
#  action                    :string(255)      not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  view                      :string(255)
#  status_id                 :integer
#  message                   :string(255)
#  response_code             :integer
#  current_resolution_height :integer
#  current_resolution_width  :integer
#  mouse_pos_x               :integer
#  mouse_pos_y               :integer
#  ip                        :string(255)
#

class UserSessionEvent < ApplicationRecord
  belongs_to :user_session
  belongs_to :status, class_name: 'UserSessionStatus'

  validates :controller, presence: true
  validates :action, presence: true
end

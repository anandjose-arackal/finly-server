# == Schema Information
#
# Table name: web_hook_tracks
#
#  id                :integer          not null, primary key
#  web_hook_id       :integer
#  web_hook_event_id :integer
#  company_id        :integer
#  url               :text(65535)
#  request_body      :text(65535)
#  request_header    :text(65535)
#  response_time     :decimal(10, )
#  response_body     :text(16777215)
#  response_status   :integer
#  attempt           :integer
#  last_attempted_at :datetime
#  attempt_success   :boolean
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class WebHookTrack < ApplicationRecord
  belongs_to :web_hook_event, optional: true
  belongs_to :company, optional: true
  belongs_to :web_hook, optional: true

  serialize :request_header, JSON
  serialize :request_body, JSON
  serialize :response_body, JSON
end
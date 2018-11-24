# == Schema Information
#
# Table name: tracker_events
#
#  id               :integer          not null, primary key
#  http_method      :string(255)
#  app              :string(255)
#  path             :string(255)
#  controller       :string(255)      not null
#  action           :string(255)      not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  tracker_visit_id :integer
#

class TrackerEvent < ActiveRecord::Base
  belongs_to :tracker_visit
end

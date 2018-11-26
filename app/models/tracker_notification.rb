# == Schema Information
#
# Table name: tracker_notifications
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  company_id :integer          not null
#  app        :string(255)
#  device     :string(255)
#  view       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TrackerNotification < ActiveRecord::Base
  belongs_to :user
  belongs_to :company
end

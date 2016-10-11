# == Schema Information
#
# Table name: event_configurations
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  event_id                :integer          not null
#  allow_push_notification :boolean
#  allow_mailer            :boolean
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#


class EventConfiguration < ActiveRecord::Base
  belongs_to :user
  belongs_to :event

  scope :with_event, ->(id) { where event_id: id }
  scope :with_user, ->(id) { where user_id: id }
end

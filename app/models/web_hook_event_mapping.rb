# == Schema Information
#
# Table name: web_hook_event_mappings
#
#  id                :integer          not null, primary key
#  web_hook_id       :integer          not null
#  web_hook_event_id :integer          not null
#  is_deleted        :boolean          default(FALSE)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class WebHookEventMapping < ApplicationRecord
  include SoftDeletable

  belongs_to :web_hook, optional: true
  belongs_to :web_hook_event, optional: true

  validates :web_hook_event, presence: true
  # validates :web_hook, presence: true

  scope :having_web_hook_id, -> (hook_id) { where web_hook_id: hook_id }
  scope :having_event_id, ->  (event_id) { where web_hook_event_id: event_id }
  scope :pluck_web_hook_id, -> { pluck :web_hook_id }
end

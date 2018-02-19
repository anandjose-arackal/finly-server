class WebHookEventMapping < ActiveRecord::Base
  include SoftDeletable

  belongs_to :web_hook
  belongs_to :web_hook_event

  validates :web_hook_event, presence: true
  # validates :web_hook, presence: true
end

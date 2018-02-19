class WebHook < ActiveRecord::Base
  include SoftDeletable

  belongs_to :created_by_user, class_name: 'User'
  belongs_to :company

  validates :created_by_user_id, presence: true
  validates :url, presence: true, uniqueness: {scope: :company_id, case_sensitive: false},format: {:with => Constants::VALID_DOMAIN}
  validates :secret, uniqueness: {allow_nil: true, scope: :company_id, case_sensitive: false}

  has_many :web_hook_event_mappings, dependent: :destroy
  has_many :web_hook_events, through: :web_hook_event_mappings

  # validates :web_hook_events, presence: true

  accepts_nested_attributes_for :web_hook_event_mappings
end

# == Schema Information
#
# Table name: web_hooks
#
#  id                 :integer          not null, primary key
#  url                :text(65535)      not null
#  secret             :string(255)
#  created_by_user_id :integer          not null
#  company_id         :integer          not null
#  is_deleted         :boolean          default(FALSE)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  headers            :text(65535)
#  deleted_at         :datetime
#

class WebHook < ApplicationRecord
  include SoftDeletable

  belongs_to :created_by_user, optional: true, class_name: 'User'
  belongs_to :company, optional: true

  serialize :headers, Hash

  validates :created_by_user_id, presence: true
  # validates :url, presence: true, uniqueness: {scope: :company_id, case_sensitive: false}, format: {:with => Constants::VALID_DOMAIN}
  validates :secret, uniqueness: {allow_nil: true, scope: :company_id, case_sensitive: false}

  has_many :web_hook_event_mappings, dependent: :destroy
  has_many :web_hook_events, through: :web_hook_event_mappings

  has_many :web_hook_tracks

  scope :having_event_id, -> (event_id) do
    ids = pluck(:id)
    filtered_ids = WebHookEventMapping.having_event_id(event_id).having_web_hook_id(ids).pluck_web_hook_id
    with_id(filtered_ids)
  end
  scope :with_id, ->(id) { where id: id }

  # validates :web_hook_events, presence: true

  accepts_nested_attributes_for :web_hook_event_mappings
end

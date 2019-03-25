class UserAgentClient < ApplicationRecord
  belongs_to :user
  belongs_to :status, class_name: 'UserAgentClientStatus'

  validates :user_agent, presence: true
  validates :user_id, presence: true
  validates :status_id, presence: true
end

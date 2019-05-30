# == Schema Information
#
# Table name: user_agent_clients
#
#  id                                :bigint           not null, primary key
#  user_agent                        :string(255)      not null
#  user_id                           :integer          not null
#  status_id                         :integer          not null
#  verification_mode                 :string(255)
#  verification_key                  :string(255)
#  verification_code_sent_at         :datetime
#  verified_at                       :datetime
#  verification_code_count           :integer
#  verification_code_failed_attempts :integer
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

class UserAgentClient < ApplicationRecord
  belongs_to :user
  belongs_to :status, class_name: 'UserAgentClientStatus'

  validates :user_agent, presence: true
  validates :user_id, presence: true
  validates :status_id, presence: true
end

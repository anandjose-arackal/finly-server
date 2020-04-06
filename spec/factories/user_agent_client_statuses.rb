# == Schema Information
#
# Table name: user_agent_client_statuses
#
#  id         :bigint           not null, primary key
#  name       :string(255)      not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :datetime
#

FactoryBot.define do
  factory :user_agent_client_status do
    
  end
end

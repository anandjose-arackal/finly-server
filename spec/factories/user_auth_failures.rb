# == Schema Information
#
# Table name: user_auth_failures
#
#  id         :bigint           not null, primary key
#  user_id    :integer          not null
#  locked     :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  ip         :string(255)
#

FactoryBot.define do
  factory :user_auth_failure do
    user { nil }
    locked { false }
  end
end

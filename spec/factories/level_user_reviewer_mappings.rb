# == Schema Information
#
# Table name: level_user_reviewer_mappings
#
#  id           :integer          not null, primary key
#  level_id     :integer
#  user_id      :integer
#  reviewer_id  :integer
#  policy_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  threshold    :decimal(20, 5)   default(0.0)
#  exception    :boolean          default(TRUE)
#  wo_exception :boolean          default(TRUE)
#

FactoryBot.define do
  factory :level_user_reviewer_mapping do
    
  end
end

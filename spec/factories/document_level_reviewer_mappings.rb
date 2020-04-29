# == Schema Information
#
# Table name: document_level_reviewer_mappings
#
#  id                              :integer          not null, primary key
#  policy_id                       :integer
#  level_id                        :integer
#  reviewer_id                     :integer
#  document_reviewer_mappable_id   :integer          not null
#  document_reviewer_mappable_type :string(255)      not null
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  level_number                    :integer
#  taken_control                   :boolean          default(FALSE)
#  taken_control_by_id             :integer
#  viewable                        :boolean          default(FALSE)
#  action_taken_by_id              :integer
#  action_id                       :integer
#  provider_name                   :string(255)
#  threshold                       :decimal(20, 5)
#  active                          :boolean          default(TRUE)
#  wo_exception                    :boolean          default(TRUE)
#  forwarded                       :boolean          default(FALSE)
#  forwarded_by_id                 :integer
#  forwarded_to_id                 :integer
#  min                             :decimal(20, 5)   default(0.0)
#  max                             :decimal(20, 5)
#  rejected_by_id                  :integer
#  action_taken_at                 :datetime
#  deleted_at                      :datetime
#  tat                             :integer
#  tat_added_by_script             :boolean          default(FALSE)
#

FactoryBot.define do
  factory :document_level_reviewer_mapping do
    
  end
end

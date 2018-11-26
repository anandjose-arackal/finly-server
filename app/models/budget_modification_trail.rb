# == Schema Information
#
# Table name: budget_modification_trails
#
#  id                  :integer          not null, primary key
#  budget_id           :integer
#  action_user_id      :integer
#  action_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  previous_value      :string(255)
#  current_value       :string(255)
#  changed_column_name :string(255)
#

class BudgetModificationTrail < ActiveRecord::Base
  belongs_to :budget
end

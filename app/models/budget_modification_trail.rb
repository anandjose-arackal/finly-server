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
  belongs_to :budget_modification_action
  belongs_to :action_user, class_name: 'User'
  belongs_to :action, class_name: 'BudgetModificationAction'

  validates :action_user, presence: true
  validates :action, presence: true

  def generate_in_words

    statement = "#{self.action_user.name} "

    case self.action_id
      when BudgetModificationAction.id_for(:add_amount)
        statement += "increased the budget amount to #{self.current_value}"
      when BudgetModificationAction.id_for(:reduce_amount)
        statement += "reduced the budget amount to #{self.current_value}"
      else
        # do nothing?
    end

    statement
  end

end

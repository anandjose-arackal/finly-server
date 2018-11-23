# == Schema Information
#
# Table name: budget_modification_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BudgetModificationAction < ActiveRecord::Base
end

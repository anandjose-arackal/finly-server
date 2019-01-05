# == Schema Information
#
# Table name: budget_modification_actions
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class BudgetModificationAction < ApplicationRecord

  include Seedable

  def self.values
    [:add_amount, :reduce_amount, :change_start_date, :change_end_date, :change_name]
  end
end

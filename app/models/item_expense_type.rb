# == Schema Information
#
# Table name: item_expense_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ItemExpenseType < ApplicationRecord
  include Seedable

  def self.values
    [:capex, :opex]
  end

  def capex?
    self.id == ItemExpenseType.id_for(:capex)
  end

  def opex?
    self.id == ItemExpenseType.id_for(:opex)
  end

end

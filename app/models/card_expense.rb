# == Schema Information
#
# Table name: card_expenses
#
#  id                  :integer          not null, primary key
#  editable_merchant   :text(65535)
#  card_transaction_id :integer
#  expense_id          :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#


class CardExpense < ActiveRecord::Base
  belongs_to :card_transaction
  belongs_to :expense # foreign key would be expense_id

  def card_merchant_name
    self.editable_merchant
  end
end

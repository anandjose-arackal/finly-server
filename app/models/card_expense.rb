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
#  surcharge_id        :integer
#  is_deleted          :boolean          default(FALSE)
#

class CardExpense < ActiveRecord::Base
  include SoftDeletable

  belongs_to :card_transaction
  belongs_to :expense # foreign key would be expense_id
  belongs_to :surcharge, class_name: 'Amount'

  accepts_nested_attributes_for :surcharge

  around_destroy :destroy_associated_expense

  def surcharge_amount
    self.surcharge.value
  end

  def card_merchant_name
    self.editable_merchant
  end

  scope :merchant_like, -> (merchant, expense_ids) do
    where(expense_id: expense_ids).where('lower(editable_merchant) LIKE ?', "%#{merchant.downcase}%").pluck(:editable_merchant)
  end

  private

  # method tod estroy an orphaned expense if there is not assocyed manual expense
  def destroy_associated_expense
    expense = self.expense
    yield
    expense.reload
    expense.destroy if expense.card_expense.nil?
  end

end

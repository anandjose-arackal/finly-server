class DuplicateExpenseMapping < ActiveRecord::Base
  belongs_to :expense, class_name: 'Expense'
  belongs_to :duplicate_expense, class_name: 'Expense'

  scope :expense_with_duplicates, ->(exp_1, exp_2) { where('(expense_id IN (?) AND duplicate_expense_id IN (?)) OR (expense_id IN (?) AND duplicate_expense_id IN (?))', exp_1, exp_2, exp_2, exp_1) }
  scope :with_expense, ->(exp_id) { where expense_id: exp_id }
  scope :with_duplicate_expense, ->(exp_id) { where duplicate_expense_id: exp_id }
  scope :with_id, ->(id) { where id: id }
  scope :without_id, ->(id) { where.note id: id }

  validates :expense_id, presence: true
  validates :duplicate_expense_id, presence: true
  validate :unique_mappings

  protected
  def unique_mappings
    if DuplicateExpenseMapping.with_expense(self.expense_id).with_duplicate_expense(self.duplicate_expense_id).without_id(self.id).present?
      errors.add :duplicate, 'configuration already present'
    end
  end
end

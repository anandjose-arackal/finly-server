# == Schema Information
#
# Table name: budgets
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  period_id        :integer
#  start_date       :date
#  end_date         :date
#  budget_amount_id :integer
#  spent_amount_id  :integer
#  budgetable_id    :integer          not null
#  budgetable_type  :string(255)      not null
#  is_deleted       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  company_id       :integer
#

class Budget < ActiveRecord::Base
  include SoftDeletable

  belongs_to :user
  belongs_to :company
  belongs_to :period
  belongs_to :budget_amount, class_name: "Amount"
  belongs_to :spent_amount, class_name: "Amount"

  belongs_to :budgetable, polymorphic: true

  accepts_nested_attributes_for :budget_amount

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validates :budgetable_id, presence: true
  validates :budgetable_type, presence: true
  validates :period_id, presence: true

  scope :with_id, -> (ids) {where id: ids}

  scope :with_budgetable_user_id, -> (ids) {where budgetable_id: ids, budgetable_type: "User"}
  scope :with_budgetable_category_id, -> (ids) {where budgetable_id: ids, budgetable_type: "Category"}
  scope :with_budgetable_vendor_id, -> (ids) {where budgetable_id: ids, budgetable_type: "YesBankVendor"}
  scope :with_budgetable_field_drop_down_item, -> (ids)  { where budgetable_type: "FieldDropDownItem", budgetable_id: ids }
end

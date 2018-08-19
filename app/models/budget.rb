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
#  budgetable_id    :integer
#  budgetable_type  :string(255)
#  is_deleted       :boolean          default(FALSE)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  user_id          :integer
#  company_id       :integer
#  purchase_order   :boolean
#  payment          :boolean
#  expense          :boolean
#

class Budget < ActiveRecord::Base
  include SoftDeletable

  has_ancestry

  belongs_to :user
  belongs_to :company
  belongs_to :period
  belongs_to :budget_amount, class_name: "Amount"
  belongs_to :spent_amount, class_name: "Amount"

  has_many :budget_criteria_mappings
  has_many :budgetables, through: :budget_criteria_mappings
  has_many :budgetable_vendors, through: :budget_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_criteria_mappings, source: :budgetable, source_type: 'Department'

  accepts_nested_attributes_for :budget_amount
  accepts_nested_attributes_for :budget_criteria_mappings

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  # validates :budgetable_id, presence: true
  # validates :budgetable_type, presence: true
  # validates :period_id, presence: true

  scope :with_id, -> (ids) {where id: ids}

  scope :applicable_to_purchase_orders, -> {
    where purchase_order: true
  }
  scope :applicable_to_expenses, -> {
    where expense: true
  }
  scope :applicable_to_payments, -> {
    where payment: true
  }

  # todo - change this to reflect the new structure
  # scope :with_budgetable_user_id, -> (ids) {where budgetable_id: ids, budgetable_type: "User"}
  # scope :with_budgetable_category_id, -> (ids) {where budgetable_id: ids, budgetable_type: "Category"}
  # scope :with_budgetable_yes_bank_vendor_id, -> (ids) {where budgetable_id: ids, budgetable_type: "YesBankVendor"}
  # scope :with_budgetable_field_drop_down_item, -> (ids)  { where budgetable_type: "FieldDropDownItem", budgetable_id: ids }
  # scope :with_budgetable_cost_center_id, -> (ids)  { where budgetable_type: "CostCenter", budgetable_id: ids }
end

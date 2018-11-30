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
#  ancestry         :string(255)
#

class Budget < ActiveRecord::Base
  include SoftDeletable

  has_ancestry
  has_many :budget_children, class_name: 'Budget', foreign_key: 'ancestry'


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

  has_many :budget_modification_trails

  accepts_nested_attributes_for :budget_amount
  accepts_nested_attributes_for :budget_criteria_mappings

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  scope :with_id, -> (ids) {where id: ids}
  scope :filter_ids, -> (id) {
    id = id.split(",")
    where id: id
  }

  scope :applicable_to_purchase_orders, -> {
    where purchase_order: true
  }
  scope :applicable_to_expenses, -> {
    where expense: true
  }
  scope :applicable_to_payments, -> {
    where payment: true
  }

  scope :with_budgetable_vendors, -> (vendor_ids) {
    if vendor_ids.present?
      vendor_ids = [vendor_ids] unless vendor_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "YesBankVendor").where('budget_criteria_mappings.budgetable_id IN (?)', vendor_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_cost_centers, -> (cost_center_ids) {
    if cost_center_ids.present?
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "CostCenter").where('budget_criteria_mappings.budgetable_id IN (?)', cost_center_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_categories, -> (category_ids) {
    if category_ids.present?
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Category").where('budget_criteria_mappings.budgetable_id IN (?)', category_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_locations, -> (location_ids) {
    if location_ids.present?
      location_ids = [location_ids] unless location_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "BranchLocation").where('budget_criteria_mappings.budgetable_id IN (?)', location_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_users, -> (user_ids) {
    if user_ids.present?
      user_ids = [user_ids] unless user_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "User").where('budget_criteria_mappings.budgetable_id IN (?)', user_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_departments, -> (department_ids) {
    if department_ids.present?
      department_ids = [department_ids] unless department_ids.is_a?(Array)
      ids = joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Department").where('budget_criteria_mappings.budgetable_id IN (?)', department_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :contains_date, -> (date) {
    where('start_date <= ? AND end_date >= ?', date, date)
  }

  scope :filter_date, -> (date_from, date_to) {
    where.not('end_date < ? AND start_date > ?', Date.parse(date_from), Date.parse(date_to))
  }

  scope :filter_year, -> (year) {
    if year.blank?
      year = Date.today.year
    end
    where('extract(year from start_date) = ? OR extract(year from end_date) = ?', year, year)
  }

  scope :filter_month, -> (month) {
    if month.present?
      where('extract(month from start_date) = ? OR extract(month from end_date) = ?', month, month)
    end
  }

  scope :filter_search, -> (term) {
    if term.present?
      where('name like ?', "%#{term}%")
    end
  }

  scope :without_id, -> (id) {
    where.not(id: id)
  }

  scope :include_details, -> {
    includes([
                 # :budget_criteria_mappings,
                 :budgetable_vendors,
                 :budgetable_cost_centers,
                 :budgetable_categories,
                 :budgetable_locations,
                 :budgetable_users,
                 :budgetable_departments,
                 :user,
                 :budget_amount,
                 budget_children: [
                     # :budget_criteria_mappings,
                     :budgetable_vendors,
                     :budgetable_cost_centers,
                     :budgetable_categories,
                     :budgetable_locations,
                     :budgetable_users,
                     :budgetable_departments,
                     :user,
                     :budget_amount
                 ]
             ])
  }


  # todo - change this to reflect the new structure
  # scope :with_budgetable_user_id, -> (ids) {where budgetable_id: ids, budgetable_type: "User"}
  # scope :with_budgetable_category_id, -> (ids) {where budgetable_id: ids, budgetable_type: "Category"}
  # scope :with_budgetable_yes_bank_vendor_id, -> (ids) {where budgetable_id: ids, budgetable_type: "YesBankVendor"}
  # scope :with_budgetable_field_drop_down_item, -> (ids)  { where budgetable_type: "FieldDropDownItem", budgetable_id: ids }
  # scope :with_budgetable_cost_center_id, -> (ids)  { where budgetable_type: "CostCenter", budgetable_id: ids }
end

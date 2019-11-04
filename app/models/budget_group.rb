# == Schema Information
#
# Table name: budget_groups
#
#  id                 :bigint           not null, primary key
#  company_id         :integer
#  created_by_user_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  period_id          :integer
#  purchase_order     :boolean
#  payment            :boolean
#  expense            :boolean
#  purchase_request   :boolean
#  invoice            :boolean
#  name               :string(255)
#

class BudgetGroup < ApplicationRecord
  belongs_to :company
  belongs_to :period
  belongs_to :created_by_user, class_name: "User"

  has_many :budget_group_criteria_mappings
  has_many :budgetables, through: :budget_group_criteria_mappings
  has_many :budgetable_vendors, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Department'


  # defining the scopes for this model

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
  scope :applicable_to_purchase_requests, -> {
    where purchase_request: true
  }
  scope :applicable_to_invoices, -> {
    where invoice: true
  }
  scope :with_period_id, -> (period_id) {
    where period_id: period_id
  }

  scope :with_budgetable_vendors, -> (vendor_ids) {
    if vendor_ids.present?
      # extracting all budgets that don't have a vendor criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "YesBankVendor").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "YesBankVendor").pluck(:budget_id)

      # now extracting all budgets with a vendor criteria and filtered to just the relevant ones
      vendor_ids = [vendor_ids] unless vendor_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "YesBankVendor").where('budget_group_criteria_mappings.budgetable_id IN (?)', vendor_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_cost_centers, -> (cost_center_ids) {
    if cost_center_ids.present?
      # extracting all budgets that don't have a cost center criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "CostCenter").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "CostCenter").pluck(:budget_id)

      # now extracting all budgets with a cost center criteria and filtered to just the relevant ones
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "CostCenter").where('budget_group_criteria_mappings.budgetable_id IN (?)', cost_center_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_categories, -> (category_ids) {
    if category_ids.present?
      # extracting all budgets that don't have a Category criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "Category").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "Category").pluck(:budget_id)

      # now extracting all budgets with a Category criteria and filtered to just the relevant ones
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "Category").where('budget_group_criteria_mappings.budgetable_id IN (?)', category_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_locations, -> (location_ids) {
    if location_ids.present?
      # extracting all budgets that don't have a Location criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "BranchLocation").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "BranchLocation").pluck(:budget_id)

      # now extracting all budgets with a Location criteria and filtered to just the relevant ones
      location_ids = [location_ids] unless location_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "BranchLocation").where('budget_group_criteria_mappings.budgetable_id IN (?)', location_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_users, -> (user_ids) {
    if user_ids.present?
      # extracting all budgets that don't have a User criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "User").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "User").pluck(:budget_id)

      # now extracting all budgets with a User criteria and filtered to just the relevant ones
      user_ids = [user_ids] unless user_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "User").where('budget_group_criteria_mappings.budgetable_id IN (?)', user_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_departments, -> (department_ids) {
    if department_ids.present?
      # extracting all budgets that don't have a Department criteria
      ids = joins(:budget_group_criteria_mappings).where.not('budget_group_criteria_mappings.budgetable_type = ?', "Department").pluck(:budget_id) - joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "Department").pluck(:budget_id)

      # now extracting all budgets with a Department criteria and filtered to just the relevant ones
      department_ids = [department_ids] unless department_ids.is_a?(Array)
      ids += joins(:budget_group_criteria_mappings).where('budget_group_criteria_mappings.budgetable_type = ?', "Department").where('budget_group_criteria_mappings.budgetable_id IN (?)', department_ids).pluck(:budget_id)
      where(id: ids)
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


  def as_json(options = {})
    {
      id: id,
      name: name,
      created_by_user: created_by_user&.name,
      purchase_order: purchase_order,
      invoice: invoice,
      purchase_request: purchase_request,
      payment: payment,
      expense: expense,
      budget_group_criteria_mappings: budget_group_criteria_mappings
    }
  end
end

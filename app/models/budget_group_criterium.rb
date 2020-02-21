# == Schema Information
#
# Table name: budget_group_criteria
#
#  id                 :bigint           not null, primary key
#  name               :string(255)
#  budget_group_id    :integer
#  ancestry           :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  created_by_user_id :integer
#  company_id         :integer
#  deleted_at         :datetime
#

class BudgetGroupCriterium < ApplicationRecord

  has_ancestry

  include AncestrySupport

  belongs_to :budget_group, optional: true
  belongs_to :created_by_user, class_name: "User"
  belongs_to :company

  has_many :budget_group_criteria_mappings
  has_many :budgetables, through: :budget_group_criteria_mappings
  has_many :budgetable_vendors, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_group_criteria_mappings, source: :budgetable, source_type: 'Department'

  has_many :budgets

  after_create :include_parent_criteria_mappings
  after_create :create_related_budgets

  accepts_nested_attributes_for :budget_group_criteria_mappings

  scope :with_id, -> (ids) do
    where id: ids
  end

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
    where('name like ?', "%#{term}%")
  }

  # this will hold data about all the different time ranges of this particular
  # budget criteria - so it will contain details of the budgets will the different timeframes
  def as_json(options = {})
    time_periods = []
    budgets.select(:start_date, :end_date).each do |budget|
      time_period = "#{budget.start_date&.strftime("%d %B %Y")} - #{budget.end_date&.strftime("%d %B %Y")}"
      time_periods << time_period
    end
    {
        id: id,
        name: name,
        created_at: created_at.strftime("%Y-%m-%d"),
        period_id: self.budget_group.period_id,
        period: self.budget_group.period&.name,
        total_budgets: self.budgets.count,
        budget_group_criteria_mappings: budget_group_criteria_mappings,
        budgetable_vendors: budgetable_vendors,
        budgetable_categories: budgetable_categories,
        budgetable_cost_centers: budgetable_cost_centers,
        budgetable_locations: budgetable_locations,
        budgetable_users: budgetable_users,
        budgetable_departments: budgetable_departments,
        sub_criteria: self.children,
        budgets: budgets,
        time_periods: time_periods
    }
  end

  private

  def include_parent_criteria_mappings
    if self.parent.present?
      self.parent.budget_group_criteria_mappings.each do |map|
        unless self.budget_group_criteria_mappings.where(budgetable: map.budgetable).present?
          self.budget_group_criteria_mappings.build(budgetable: map.budgetable).save
        end
      end
    end
  end

  def create_related_budgets
    start_date = self.budget_group.start_date
    final_end_date = self.budget_group.end_date
    while start_date < final_end_date do
      end_date = BudgetManagerUtils.next_date(start_date, final_end_date, self.budget_group.period_id)
      break if end_date.blank?
      budget = self.budgets.build(
                               start_date: start_date,
                               end_date: end_date,
                               name: "#{start_date.strftime("%d %B, %Y")} - #{end_date.strftime("%d %B, %Y")}",
                               company_id: self.company_id,
                               budget_group_id: self.budget_group.id,
                               user_id: self.budget_group.created_by_user_id,
                               budget_date_type_id: self.budget_group.budget_date_type_id,
                               budget_amount_attributes: {
                                   value: 0,
                                   currency_id: 1
                               }
      )
      budget.save

      # now setting the start date as the next day of the end date
      start_date = end_date
    end
  end

end

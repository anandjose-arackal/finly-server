# == Schema Information
#
# Table name: budgets
#
#  id                           :integer          not null, primary key
#  name                         :string(255)
#  period_id                    :integer
#  start_date                   :date
#  end_date                     :date
#  budget_amount_id             :integer
#  spent_amount_id              :integer
#  budgetable_id                :integer
#  budgetable_type              :string(255)
#  is_deleted                   :boolean          default(FALSE)
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  user_id                      :integer
#  company_id                   :integer
#  purchase_order               :boolean
#  payment                      :boolean
#  expense                      :boolean
#  ancestry                     :string(255)
#  deleted_at                   :datetime
#  budget_group_id              :integer
#  calculated_before_tax_amount :boolean          default(FALSE)
#  purchase_request             :boolean
#  invoice                      :boolean
#  budget_group_criterium_id    :integer
#  active                       :boolean          default(TRUE)
#  budget_date_type_id          :integer
#

class Budget < ApplicationRecord
  include SoftDeletable, AncestrySupport

  has_ancestry
  has_many :budget_children, class_name: 'Budget', foreign_key: 'ancestry'
  has_one :budget_consumption, dependent: :destroy

  belongs_to :budget_date_type, optional: true
  belongs_to :user, optional: true
  belongs_to :company, optional: true
  belongs_to :budget_amount, optional: true, class_name: "Amount"
  belongs_to :spent_amount, optional: true, class_name: "Amount"
  belongs_to :budget_group
  belongs_to :budget_group_criterium

  # Above details like period, name, budget amount etc. will be held in the budget itself for now
  # the below will now be moved to the Budget Group which will house the details of the criteria
  ###################### DEPRECATED #########################
  has_many :budget_criteria_mappings
  has_many :budgetables, through: :budget_criteria_mappings
  has_many :budgetable_vendors, through: :budget_criteria_mappings, source: :budgetable, source_type: 'YesBankVendor'
  has_many :budgetable_cost_centers, through: :budget_criteria_mappings, source: :budgetable, source_type: 'CostCenter'
  has_many :budgetable_categories, through: :budget_criteria_mappings, source: :budgetable, source_type: 'Category'
  has_many :budgetable_locations, through: :budget_criteria_mappings, source: :budgetable, source_type: 'BranchLocation'
  has_many :budgetable_users, through: :budget_criteria_mappings, source: :budgetable, source_type: 'User'
  has_many :budgetable_departments, through: :budget_criteria_mappings, source: :budgetable, source_type: 'Department'
  ###################### DEPRECATED #########################

  has_many :budget_modification_trails
  has_one :budget_consumption

  accepts_nested_attributes_for :budget_amount
  accepts_nested_attributes_for :budget_criteria_mappings

  validates :name, presence: true
  validates :start_date, presence: true
  validates :end_date, presence: true

  after_create :set_budget_consumption
  after_create :reflect_budget_group_attributes
  after_save :update_consumption_model

  after_update :recalculate_parent_budget
  after_update :reassign_parent_mappings

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
      # extracting all budgets that don't have a vendor criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "YesBankVendor").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "YesBankVendor").pluck(:budget_id)

      # now extracting all budgets with a vendor criteria and filtered to just the relevant ones
      vendor_ids = [vendor_ids] unless vendor_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "YesBankVendor").where('budget_criteria_mappings.budgetable_id IN (?)', vendor_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_cost_centers, -> (cost_center_ids) {
    if cost_center_ids.present?
      # extracting all budgets that don't have a cost center criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "CostCenter").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "CostCenter").pluck(:budget_id)

      # now extracting all budgets with a cost center criteria and filtered to just the relevant ones
      cost_center_ids = [cost_center_ids] unless cost_center_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "CostCenter").where('budget_criteria_mappings.budgetable_id IN (?)', cost_center_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_categories, -> (category_ids) {
    if category_ids.present?
      # extracting all budgets that don't have a Category criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "Category").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Category").pluck(:budget_id)

      # now extracting all budgets with a Category criteria and filtered to just the relevant ones
      category_ids = [category_ids] unless category_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Category").where('budget_criteria_mappings.budgetable_id IN (?)', category_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_locations, -> (location_ids) {
    if location_ids.present?
      # extracting all budgets that don't have a Location criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "BranchLocation").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "BranchLocation").pluck(:budget_id)

      # now extracting all budgets with a Location criteria and filtered to just the relevant ones
      location_ids = [location_ids] unless location_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "BranchLocation").where('budget_criteria_mappings.budgetable_id IN (?)', location_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_users, -> (user_ids) {
    if user_ids.present?
      # extracting all budgets that don't have a User criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "User").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "User").pluck(:budget_id)

      # now extracting all budgets with a User criteria and filtered to just the relevant ones
      user_ids = [user_ids] unless user_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "User").where('budget_criteria_mappings.budgetable_id IN (?)', user_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :with_budgetable_departments, -> (department_ids) {
    if department_ids.present?
      # extracting all budgets that don't have a Department criteria
      ids = joins(:budget_criteria_mappings).where.not('budget_criteria_mappings.budgetable_type = ?', "Department").pluck(:budget_id) - joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Department").pluck(:budget_id)

      # now extracting all budgets with a Department criteria and filtered to just the relevant ones
      department_ids = [department_ids] unless department_ids.is_a?(Array)
      ids += joins(:budget_criteria_mappings).where('budget_criteria_mappings.budgetable_type = ?', "Department").where('budget_criteria_mappings.budgetable_id IN (?)', department_ids).pluck(:budget_id)
      where(id: ids)
    end
  }

  scope :contains_date, -> (date) {
    if date.present?
      where('start_date <= ? AND end_date >= ?', Date.parse(date.to_s), Date.parse(date.to_s))
    else
      # i.e. return an empty array
      where(id: [])
    end
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
    if month.blank?
      month = Date.today.month
    end
    where('extract(month from start_date) = ? OR extract(month from end_date) = ?', month, month)
  }

  scope :filter_search, -> (term) {
    if term.present?
      where('name like ?', "%#{term}%")
    end
  }

  scope :without_id, -> (id) {
    where.not(id: id)
  }

  scope :filter_budget_group_id, -> (budget_group_id) {
    where budget_group_id: budget_group_id
  }

  scope :with_budget_criteria_id, -> (budget_criteria_ids) {
    where budget_group_criterium_id: budget_criteria_ids
  }

  scope :active, -> {
    where active: true
  }

  # scope :filter_criteria, -> (criteria) {
  #   case criteria
  #   when 'budget', :budget, '1'

  #   when 'timeline', :timeline, '2'

  #   end
  # }

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

  def as_json(options = {})
    budget_criteria_id = budget_group_criterium&.id
    get_budget_criteria_as_json(budget_criteria_id)
  end

  def get_budget_criteria_as_json(budget_criteria_id = nil)
    {
        id: id,
        name: name,
        active: active,
        start_date: start_date&.strftime("%d-%b-%Y"),
        end_date: end_date&.strftime("%d-%b-%Y"),
        budget_amount: budget_consumption.budget_amount.as_json,
        spent_amount: budget_consumption.total_consumed_amount.as_json,
        budget_consumption: budget_consumption,
        budget_group: budget_group,
        # spent_amount: processor_instance.spent_amount,
        criteria_name: budget_group_criterium&.name,
        associated_vendors: budget_group_criterium&.budgetable_vendors&.collect {|vendor| {id: vendor.id, name: (vendor.name || vendor.business_name)}},
        associated_categories: budget_group_criterium&.budgetable_categories.as_json,
        associated_cost_centers: budget_group_criterium&.budgetable_cost_centers.as_json,
        associated_locations: budget_group_criterium&.budgetable_locations.as_json,
        associated_departments: budget_group_criterium&.budgetable_departments.as_json,
        associated_users: budget_group_criterium&.budgetable_users&.collect {|vendor| {id: vendor.id, name: vendor.name}},
        user: {
            id: user.id,
            mobile_number: user.mobile_number,
            email: user.email

        },
        criteria_id: budget_criteria_id,
        sub_budgets: get_sub_budgets_as_json(budget_criteria_id),
        sub_budgets_count: budget_group_criterium&.children&.map(&:budgets)&.flatten&.count
    }
  end

  def get_sub_budgets_as_json(budget_criteria_id = nil)
    data = []
    budget_group_criterium&.children.each {|child| child.budgets&.each {|budget| data << budget.get_budget_criteria_as_json(budget_criteria_id)}}
    data
  end

  def budget_criteria_as_json(options = {})
    budget_criteria_id = budget_group_criterium&.id
    get_budget_criteria_as_json(budget_criteria_id)
  end

  def timeline_criteria_as_json(options = {})
    {
        id: id,
        name: name,
        start_date: start_date&.strftime("%d-%b-%Y"),
        end_date: end_date&.strftime("%d-%b-%Y"),
        budget_amount: budget_amount.as_json,
        budget_consumption: budget_consumption,
        sub_budgets: children.map(&:timeline_criteria_as_json),
        sub_budgets_count: children.size,
    }
  end

  def only_name_as_json
    {
        id: id,
        name: name,
        sub_budgets: children.map(&:only_name_as_json)
    }
  end

  def criteria_as_json(options = {})

  end

  def consumed_budget
    # calculate in percentage how much budget amount is actually spent
    ((processor_instance.spent_amount / self.budget_amount.value) * 100) rescue 0
  end

  def validate_if_owner?(user)
    self.user_id == user.id
  end

  def validate_if_manager?(user)
    user.is_budget_manager?
  end

  def validate_if_admin?(user)
    user.admin? || user.vp_admin_or_auditor?
  end

  def within_timeframe?(date)
    true if (start_date <= date and end_date >= date)
  end

  private

  def processor_instance
    BudgetManager::BudgetsCalculator::Calculate::BudgetsProcessor.new(self)
  end

  def recalculate_parent_budget
    # parent budget amount should not be dependent on the sum of its child budgets amount
    # if self.parent.present?
    #   sum_children = self.parent.children.joins(:budget_amount).sum(:value)
    #   self.parent.budget_amount.update(value: sum_children)
    # end
  end

  def reassign_parent_mappings
    if self.parent.present?
      self.parent.children.each do |child_budget|
        budget_criteria_mappings = child_budget.budget_criteria_mappings
        budget_criteria_mappings.each do |mapping|
          next if self.parent.budget_criteria_mappings.with_budgetable_type(mapping.budgetable_type).with_budgetable_id(mapping.budgetable_id).present?
          self.parent.budget_criteria_mappings.build(budgetable_type: mapping.budgetable_type, budgetable_id: mapping.budgetable_id).save
        end
      end
    end
  end

  # initializing the budget consumption model with default values
  # currently being done here because TBZ doesn't have very good callbacks
  def set_budget_consumption
    budget_consumption = self.build_budget_consumption(
        budget_amount_attributes: {
            value: self.budget_amount.value,
            currency: Currency.first
        },
        pending_amount_attributes: {
            value: 0,
            currency: Currency.first
        },
        committed_amount_attributes: {
            value: 0,
            currency: Currency.first
        },
        pending_payment_amount_attributes: {
            value: 0,
            currency: Currency.first
        },
        payment_processing_amount_attributes: {
            value: 0,
            currency: Currency.first
        },
        paid_amount_attributes: {
            value: 0,
            currency: Currency.first
        },
        remaining_amount_attributes: {
            value: self.budget_amount.value,
            currency: Currency.first
        },
        total_consumed_amount_attributes: {
            value: 0,
            currency: Currency.first
        }
    )
    budget_consumption.save
  end

  def update_consumption_model
    op = BudgetManager::BudgetsCalculator::Calculate::BudgetsComputer.({budget: self, current_user: User.first, calculate_buckets: true, calculate_trail_items: false})
  end

  def reflect_budget_group_attributes
    self.update_attributes(
        purchase_order: self.budget_group.purchase_order,
        invoice: self.budget_group.invoice,
        purchase_request: self.budget_group.purchase_request,
        expense: self.budget_group.expense,
        payment: self.budget_group.payment
    )
  end

end

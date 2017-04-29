# == Schema Information
#
# Table name: budget_rules
#
#  id                   :integer          not null, primary key
#  category_id          :integer
#  amount_id            :integer
#  period_id            :integer
#  policy_id            :integer
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  rule_type_id         :integer
#  include_reimbursable :boolean          default(TRUE)
#





class BudgetRule < ActiveRecord::Base
  belongs_to :category
  belongs_to :amount
  belongs_to :period
  belongs_to :policy
  belongs_to :rule_type

  accepts_nested_attributes_for :amount

  # delegate :period, to: :period
  delegate :type, to: :rule_type
  delegate :amount_value, to: :amount
  delegate :category_name, to: :category

  validates :period_id, presence: true
  validates :policy_id, presence: true
  validates :rule_type_id, presence: true

  validate :no_duplicates

  before_create :update_parent_version
  before_destroy :update_parent_version

  has_paper_trail

  def include_reimbursable_expenses?
    self.include_reimbursable
  end

  private
  def update_parent_version
    self.policy.update_attribute(:updated_at, DateTime.now)
  end

  # todo - look for a more elegant way to do this. Shitty code.
  def no_duplicates
    # checking against all budget rules in the respective policy
    self.policy.budget_rules.each do |rule|
      if not rule.id == self.id and rule.amount_value == self.amount_value and rule.category_id == self.category_id and rule.period_id == self.period_id and rule.rule_type_id == self.rule_type_id
        errors.add(:rules, 'already exists. Please try again.')
      end
    end
  end

end

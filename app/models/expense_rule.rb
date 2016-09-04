# == Schema Information
#
# Table name: expense_rules
#
#  id                     :integer          not null, primary key
#  greater_than_amount_id :integer
#  category_id            :integer
#  days_after             :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  rule_type_id           :integer
#  expense_rule_type_id   :integer
#  policy_id              :integer
#

class ExpenseRule < ActiveRecord::Base
  belongs_to :greater_than_amount, class_name: "Amount"
  belongs_to :category

  belongs_to :rule_type
  belongs_to :expense_rule_type
  belongs_to :policy

  accepts_nested_attributes_for :greater_than_amount

  delegate :amount_value, to: :greater_than_amount
  delegate :greater_than_amount_value, to: :greater_than_amount
  delegate :type, to: :rule_type
  delegate :category_name, to: :category


  validates :policy_id, presence: true
  validates :rule_type_id, presence: true
  validates :expense_rule_type_id, presence: true

  validate :no_duplicates

  before_create :update_parent_version
  before_destroy :update_parent_version

  has_paper_trail

  private
  def update_parent_version
    self.policy.update_attribute(:updated_at, DateTime.now)
  end

  # todo - look for a more elegant way to do this. Shitty code.
  # make sure no rule has all attributes the same
  def no_duplicates
    self.policy.expense_rules.each do |rule|
      if not rule.id == self.id and rule.amount_value == self.amount_value and rule.category_id == self.category_id and rule.days_after == self.days_after and rule.expense_rule_type_id == self.expense_rule_type_id and rule.rule_type_id == self.rule_type_id
        errors.add(:rule, 'already exists. Please try again.')
      end
    end

  end

end

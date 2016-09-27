# == Schema Information
#
# Table name: user_manager_mappings
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  manager_id             :integer
#  finance_manager_id     :integer
#  approves_to_id         :integer
#  approves_finance_to_id :integer
#  greater_than_amount_id :integer
#  default                :boolean          default(FALSE), not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  policy_id              :integer
#

class UserManagerMapping < ActiveRecord::Base
  include PolicyVersion

  belongs_to :user
  belongs_to :manager, class_name: 'User'
  belongs_to :finance_manager, class_name: 'User'
  belongs_to :approves_to, class_name: 'User'
  belongs_to :approves_finance_to, class_name: 'User'
  belongs_to :greater_than_amount, class_name: 'Amount', dependent: :destroy
  belongs_to :policy
  accepts_nested_attributes_for :greater_than_amount

  delegate :greater_than_amount_value, to: :greater_than_amount
  delegate :greater_than_amount_currency_id, to: :greater_than_amount

  validate :valid_default
  validate :valid_non_default

  scope :with_id, ->(id) { where id: id }
  scope :without_id, ->(id) { where.not id: id }
  scope :with_user, -> (user_id) { where user_id: user_id }
  scope :default, -> { where default: true }
  scope :non_default, -> { where.not default: true }
  scope :policy, -> (policy_id) { where policy_id: policy_id }
  scope :without_policy, ->{ where policy_id: nil }
  scope :sort, ->(sort_by, order) do
    order.upcase! if order
    order("#{sort_by} #{order}") #sort_by: created_at, date etc. order: asc/desc
  end
  scope :manager, -> { where 'manager_id IS NOT NULL' }
  scope :finance_manager, -> { where 'finance_manager_id IS NOT NULL' }
  scope :approves_to, -> { where 'approves_to_id IS NOT NULL' }
  scope :approves_finance_to, -> { where 'approves_finance_to_id IS NOT NULL' }

  scope :amount, ->(currency_id, value) do
    if value.blank? or currency_id.blank?
      self.default
    else
      item = joins(:greater_than_amount).where('value <= ? AND currency_id = ?', value, currency_id).order('value DESC').limit(1)
      if item.present?
        item
      else
        self.default
      end
    end
  end
  scope :exact_amount, ->(currency_id, value) do
    joins(:greater_than_amount).where('value = ? AND currency_id = ?', value, currency_id)
  end
  scope :manager_team, ->(policy_id, manager_id) { where policy_id: policy_id, manager_id: manager_id }
  scope :finance_team, ->(policy_id, finance_manager_id) { where policy_id: policy_id, finance_manager_id: finance_manager_id }
  scope :company, ->(company_id) { joins(:policy).where(company_id: company_id) }

  scope :has_finance_manager, ->(manager_id) { where finance_manager_id: manager_id }
  scope :has_approves_finance_to, ->(manager_id) { where approves_finance_to_id: manager_id }
  scope :has_manager, ->(manager_id) { where manager_id: manager_id }
  scope :has_approves_to, ->(manager_id) { where approves_to_id: manager_id }

  scope :with_details, -> { includes :user, :manager, :finance_manager, :approves_to, :approves_finance_to, :greater_than_amount }

  def manager_name
    return nil unless self.manager_id
    User.find_by(id: self.manager_id).name
  end

  def finance_manager_name
    return nil unless self.finance_manager_id
    User.find_by(id: self.finance_manager_id).name
  end

  def approves_to_name
    return nil unless self.approves_to_id
    User.find_by(id: self.approves_to_id).name
  end

  def approves_finance_to_name
    return nil unless self.approves_finance_to_id
    User.find_by(id: self.approves_finance_to_id).name
  end

  private
  def valid_default
    if default and greater_than_amount.present?
      errors.add(:cannot, 'set greater than amount for default configuration')
    end
  end

  def valid_non_default
    if greater_than_amount.blank? and not default
      errors.add(:greater_than_amount, 'cannot be blank')
    end
  end


end

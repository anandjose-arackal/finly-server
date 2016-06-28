class UserManagerMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager, class_name: "User"
  belongs_to :finance_manager, class_name: "User"
  belongs_to :approves_to_user, class_name: "User"
  belongs_to :approves_finance_to_user, class_name: "User"
  belongs_to :greater_than_amount, class_name: "Amount", dependent: :destroy
  belongs_to :policy

  validate :valid_default
  validate :valid_non_default

  scope :user, -> (user) { where user_id: user.id }
  scope :default, -> { find_by default: true }
  scope :policy, -> (policy_id) { where policy_id: policy_id }
  scope :sort, ->(sort_by, order) do
    order.upcase! if order
    order("#{sort_by} #{order}") #sort_by: created_at, date etc. order: asc/desc
  end
  scope :manager, -> { where 'manager_id IS NOT NULL' }
  scope :finance_manager, -> { where 'finance_manager_id IS NOT NULL' }
  scope :approves_to, -> { where 'approves_to_user_id IS NOT NULL' }
  scope :approves_finance_to, -> { where 'approves_finance_to_user_id IS NOT NULL' }
  scope :amount, ->(currency_id, value) do
    item = joins(:greater_than_amount).where('value <= ? AND currency_id = ?', value, currency_id)
               .order('value DESC').limit(1)
    if item.present?
      item.first
    else
      self.default
    end
  end

  private
  def valid_default
    if default and greater_than_amount.present? and greater_than_amount.value > 0
      errors.add(:cannot, "set greater than amount for default configuration")
    end
  end

  def valid_non_default
    if greater_than_amount.blank? and not default
      errors.add(:greater_than_amount, "cannot be blank")
    end
  end


end

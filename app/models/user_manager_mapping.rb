class UserManagerMapping < ActiveRecord::Base
  belongs_to :user
  belongs_to :manager, class_name: "User"
  belongs_to :finance_manager, class_name: "User"
  belongs_to :approves_to_user, class_name: "User"
  belongs_to :approves_finance_to_user, class_name: "User"
  belongs_to :greater_than_amount, class_name: "Amount"

  validate :valid_default
  validate :valid_non_default

  scope :default, -> (user){ where user_id: user.id, default: true}

  private
  def valid_default
    if greater_than_amount.present? and default
      errors.add(:cannot, "set greater than amount for default configuration")
    end
  end

  def valid_non_default
    if greater_than_amount.blank? and not default
      errors.add(:greater_than_amount, "cannot be blank")
    end
  end



end

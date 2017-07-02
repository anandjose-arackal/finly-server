# == Schema Information
#
# Table name: user_panel_subscriptions
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  disburse           :boolean
#  expense_management :boolean
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class UserPanelSubscription < ActiveRecord::Base
  belongs_to :user

  validate :at_least_one_panel

  private

  def at_least_one_panel
    if self.disburse == false && self.expense_management == false
      errors.add(:user, "must belong to at least one of the features")
    end
  end
end

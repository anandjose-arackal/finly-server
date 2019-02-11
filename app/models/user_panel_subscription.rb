# == Schema Information
#
# Table name: user_panel_subscriptions
#
#  id                        :integer          not null, primary key
#  user_id                   :integer
#  disburse                  :boolean
#  expense_management        :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  yes_bank_account_transfer :boolean
#  invoicing_system          :boolean          default(FALSE)
#  travel_request            :boolean          default(FALSE)
#

class UserPanelSubscription < ApplicationRecord
  belongs_to :user, optional: true

  validate :at_least_one_panel

  private

  def at_least_one_panel
    if self.disburse == false && self.expense_management == false && self.yes_bank_account_transfer == false && self.invoicing_system == false
      errors.add(:user, "must belong to at least one of the features")
    end
  end
end

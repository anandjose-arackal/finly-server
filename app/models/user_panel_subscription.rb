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
#  deleted_at                :datetime
#  weekly_summary_enabled    :boolean          default(FALSE)
#  company_id                :integer
#

class UserPanelSubscription < ApplicationRecord
  belongs_to :user, optional: true

  belongs_to :company, optional: true
  belongs_to :default_subscription_type, foreign_key: :default_subscription_type_id, class_name: 'FeatureSubscriptionType', optional: true


  validate :at_least_one_panel

  def default_subscription
    return self.default_subscription_type.name  if self.default_subscription_type_id.present?
    feature = ''
    if self.expense_management
      feature = 'expense_management'
    elsif  self.yes_bank_account_transfer
      feature = 'vendor_payments'
    elsif self.disburse
      feature = 'disburse'
    end
    feature
  end

  private

  def at_least_one_panel
    if self.disburse == false && self.expense_management == false && self.yes_bank_account_transfer == false && self.invoicing_system == false
      errors.add(:user, "must belong to at least one of the features")
    end
  end

\
end

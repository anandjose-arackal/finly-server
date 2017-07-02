class CreateUserPanelSubscriptionsForAllUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      unless user.user_panel_subscription.present?
        # todo - change this before deploying to production
        em = user.company.feature_subscription.expense_management_enabled
        disburse = user.company.feature_subscription.expense_card_enabled || user.company.feature_subscription.reimbursement_card_enabled || user.company.feature_subscription.medical_card_enabled || user.company.feature_subscription.fuel_card_enabled
        unless user.user_panel_subscription.present?
          user.build_user_panel_subscription(disburse: disburse, expense_management: em).save
        end
      end
    end
  end

  def down
    # nothing
  end
end

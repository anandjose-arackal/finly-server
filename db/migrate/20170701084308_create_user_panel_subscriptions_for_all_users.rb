class CreateUserPanelSubscriptionsForAllUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      unless user.user_panel_subscription.present?
        # todo - change this before deploying to production
        em_flag = ((-(user.created_at - DateTime.now).to_i)%2 == 0) ? true : false
        dis_flag = ((-(user.updated_at - DateTime.now).to_i)%2 == 0) ? true : false
        user.build_user_panel_subscription(expense_management: em_flag, disburse: dis_flag).save
      end
    end
  end

  def down
    # nothing
  end
end

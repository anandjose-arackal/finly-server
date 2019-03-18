class CatalogueVendorUserRoleMigration < ActiveRecord::Migration[5.2]
  def change
    #-------=================-------- V1 SCRIPT Condition start -------=======================---------------

    # Add 'purchase_order_initiator' to policy
    # All policy members are 'purchase_order_initiator'
    Policy.joins(:company).with_application("vp").each do |policy|
      policy.user_mapping.find_each do |mapping|
        if mapping.user.company.feature_subscription.yes_bank_account
          if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:vendor_creator)).blank?
            policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:vendor_creator))
          end
          if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager)).blank?
            policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager))
          end
        end
        if mapping.user.company.feature_subscription.budgeting_system
          if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:budget_manager)).blank?
            policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:budget_manager))
          end
        end
      end
    end
    #-------=================-------- V1 SCRIPT Condition end -------=======================--------------
  end
end

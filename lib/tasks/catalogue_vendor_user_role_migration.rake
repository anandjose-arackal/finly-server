task :catalogue_vendor_user_role_migration => :environment do

  #-------=================-------- V1 SCRIPT Condition start -------=======================---------------

  # Add 'purchase_order_initiator' to policy
  # All policy members are 'purchase_order_initiator'
  Policy.joins(:company).with_application("vp").each do |policy|
    policy.user_mapping.find_each do |mapping|
      #Check if company has access to vendor payments.
      #If yes, then all company users will automatically have access to payment_ticket hence the user  will have role as  'purchase_order_initiator' in policy user role
      # Check if user is aleady present in the policy with the 'purchase_order_initiator', if not: create it
      if mapping.user.company.feature_subscription.yes_bank_account
        if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:vendor_creator)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:vendor_creator))
        end
        if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager))
        end
      end
      # If any company users have user role as admin, then add him as admin to all policies for purchase_order
      # FOR THAT, get all company policies, add user as admin if not already present
      if mapping.user.vendor_payment_admin?
        if policy.policy_user_roles.where(user_id: mapping.user.id, user_role_id: UserRole.id_for(:admin)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user.id, user_role_id: UserRole.id_for(:admin))
        end
      end
    end
  end
  #-------=================-------- V1 SCRIPT Condition end -------=======================--------------
end
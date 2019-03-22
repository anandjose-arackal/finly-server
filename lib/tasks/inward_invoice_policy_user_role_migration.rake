task :inward_invoice_policy_user_role_migration => :environment do

  #-------=================-------- V1 SCRIPT Condition start -------=======================---------------

  # Add 'invoice_initiator' to policy
  # All policy members are 'invoice_initiator'
  Policy.joins(:company).with_application("vp").each do |policy|
    policy.user_mapping.find_each do |mapping|
      #Check if company has access to vendor payments.
      #If yes, then all company users will automatically have access to payment_ticket hence the user  will have role as  'invoice_initiator' in policy user role
      # Check if user is aleady present in the policy with the 'invoice_initiator', if not: create it
      if mapping.user.company.feature_subscription.procurement
        if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:invoice_initiator)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:invoice_initiator))
        end

        if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:item_master_manager))
        end
      end
    end


    # Find LRM and LURM for a policy levels and make the users in it as 'invoice_reviewer'
    if policy.levels.where(associated_entity_type: 'InvoiceProvider').present?
      policy.levels.where(associated_entity_type: 'InvoiceProvider').find_each do |reviewal_level|
        reviewal_level.reviewers.find_each do |reviewer|
          # If user is not already present as 'invoice_reviewer', create the policy_user_role
          if policy.policy_user_roles.where(user_id: reviewer.id, user_role_id: UserRole.id_for(:invoice_reviewer)).blank?
            policy.policy_user_roles.create!(user_id: reviewer.id, user_role_id: UserRole.id_for(:invoice_reviewer))
          end
        end
        # Add LURM users if LURM users are not present in the policy as the 'invoice_reviewer'
        if reviewal_level.level_user_reviewer_mappings.present?
          reviewal_level.level_user_reviewer_mappings.find_each do |lurm|
            # If LURM is present and not present in the current policy user role as a reviewer, add them.
            if policy.policy_user_roles.where(user_id: lurm.reviewer_id, user_role_id: UserRole.id_for(:invoice_reviewer)).blank?
              policy.policy_user_roles.create!(user_id: lurm.reviewer_id, user_role_id: UserRole.id_for(:invoice_reviewer))
            end
          end
        end
      end
    end
  end
  #-------=================-------- V1 SCRIPT Condition end -------=======================--------------
end
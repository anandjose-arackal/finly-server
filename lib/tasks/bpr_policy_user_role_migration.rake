task :bpr_policy_user_role_migration => :environment do

  #-------=================-------- V1 SCRIPT Condition start -------=======================---------------

  # Add 'bank_payment_request_initiator' to policy
  # All policy members are 'bank_payment_request_initiator'
  Policy.joins(:company).with_application("vp").each do |policy|
    policy.user_mapping.find_each do |mapping|
      #Check if company has access to vendor payments.
      #If yes, then all company users will automatically have access to payment_ticket hence the user  will have role as  'bank_payment_request_initiator' in policy user role
      # Check if user is aleady present in the policy with the 'bank_payment_request_initiator', if not: create it
      if mapping.user.company.feature_subscription.yes_bank_account
        if policy.policy_user_roles.where(user_id: mapping.user_id, user_role_id: UserRole.id_for(:bank_payment_request_initiator)).blank?
          policy.policy_user_roles.create!(user_id: mapping.user_id, user_role_id: UserRole.id_for(:bank_payment_request_initiator))
        end
      end
      # If any company users have user role as admin, then add him as admin to all policies for bank_payment_request
      # FOR THAT, get all company policies, add user as admin if not already present
      # if mapping.user.vendor_payment_admin?
      #   if policy.policy_user_roles.where(user_id: mapping.user.id, user_role_id: UserRole.id_for(:admin)).blank?
      #     policy.policy_user_roles.create!(user_id: mapping.user.id, user_role_id: UserRole.id_for(:admin))
      #   end
      # end
    end


    # Find LRM and LURM for a policy levels and make the users in it as 'bank_payment_request_reviewer'
    if policy.levels.where(associated_entity_type: 'BankPaymentRequestProvider').present?
      policy.levels.where(associated_entity_type: 'BankPaymentRequestProvider').find_each do |reviewal_level|
        reviewal_level.reviewers.find_each do |reviewer|
          # If user is not already present as 'bank_payment_request_reviewer', create the policy_user_role
          if policy.policy_user_roles.where(user_id: reviewer.id, user_role_id: UserRole.id_for(:bank_payment_request_reviewer)).blank?
            policy.policy_user_roles.create!(user_id: reviewer.id, user_role_id: UserRole.id_for(:bank_payment_request_reviewer))
          end
        end
        # Add LURM users if LURM users are not present in the policy as the 'bank_payment_request_reviewer'
        if reviewal_level.level_user_reviewer_mappings.present?
          reviewal_level.level_user_reviewer_mappings.find_each do |lurm|
            # If LURM is present and not present in the current policy user role as a reviewer, add them.
            if policy.policy_user_roles.where(user_id: lurm.reviewer_id, user_role_id: UserRole.id_for(:bank_payment_request_reviewer)).blank?
              policy.policy_user_roles.create!(user_id: lurm.reviewer_id, user_role_id: UserRole.id_for(:bank_payment_request_reviewer))
            end
          end
        end
      end
    end
    # Check if policy user role already has a role like creditor, make him document specific creditor, like bank_payment_request_creditor
    policy.policy_user_roles.find_each do |policy_user_role|
      # If policy user role has creditor and that user is not present in policy with same role in policy, make him 'bank_payment_request_creditor'
      if (policy_user_role.user_role_id == 9) && policy.policy_user_roles.where(user_id: policy_user_role.user_id, user_role_id: UserRole.id_for(:bank_payment_request_creditor)).blank?
        policy.policy_user_roles.create!(user_id: policy_user_role.user_id, user_role_id: UserRole.id_for(:bank_payment_request_creditor))
      end
    end    
  end
  #-------=================-------- V1 SCRIPT Condition end -------=======================--------------
end
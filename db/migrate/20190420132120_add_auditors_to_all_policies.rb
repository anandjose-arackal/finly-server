class AddAuditorsToAllPolicies < ActiveRecord::Migration[5.2]
  def change
    User.only_auditors.each do |user|
      policies = user.company.policies
      policies.each do |policy|
        policy.policy_user_roles.build(user_role_id: UserRole.id_for(:bank_payment_request_auditor), user_id: user.id).save
        policy.policy_user_roles.build(user_role_id: UserRole.id_for(:purchase_request_auditor), user_id: user.id).save
        policy.policy_user_roles.build(user_role_id: UserRole.id_for(:purchase_order_auditor), user_id: user.id).save
      end
    end
  end
end
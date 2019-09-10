class PoNonPoRoleMigrations < ActiveRecord::Migration[5.2]
  def change
    # copy_roles_to_po_and_non_po_invoice
    # copy_wm_to_po_and_non_po_invoice
  end


  def copy_roles_to_po_and_non_po_invoice
    # Migrate invoice reviewers and roles  to po_invoice_roles
    old_invoice_roles = [UserRole.id_for(:invoice_initiator), UserRole.id_for(:invoice_reviewer), UserRole.id_for(:invoice_auditor)]

    new_roles = [UserRole.id_for(:po_invoice_initiator), UserRole.id_for(:po_invoice_reviewer), UserRole.id_for(:po_invoice_auditor), UserRole.id_for(:non_po_invoice_initiator), UserRole.id_for(:non_po_invoice_reviewer), UserRole.id_for(:non_po_invoice_auditor)]
    Policy.joins(:company).with_application("vp").each do |policy|
      policy.policy_user_roles.where(role_id: old_invoice_roles).each do |pur|
        if pur.user_role_id == UserRole.id_for(:invoice_initiator)
          # Create Po invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_initiator)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_initiator))
          end
          # Create NonPo invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_initiator)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_initiator))
          end
        end

        if pur.user_role_id == UserRole.id_for(:invoice_reviewer)
          # Create Po invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_reviewer)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_reviewer))
          end
          # Create NonPo invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_reviewer)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_reviewer))
          end
        end

        if pur.user_role_id == UserRole.id_for(:invoice_auditor)
          # Create Po invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_auditor)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:po_invoice_auditor))
          end
          # Create NonPo invoice if not present already
          if PolicyUserRole.where(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_auditor)).blank?
            PolicyUserRole.create(policy_id: policy.id, user_id: pur.user_id, user_role_id: UserRole.id_for(:non_po_invoice_auditor))
          end
        end

      end

    end
  end

  def copy_wm_to_po_and_non_po_invoice
    Policy.joins(:company).with_application("vp").each do |policy|
      ReviewalLevel.where(policy_id: policy.id, )
    end
  end
end
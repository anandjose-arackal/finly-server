class PoNonPoRoleMigration

  def role_migration
    copy_roles_to_po_and_non_po_invoice 
    copy_to_po_invoice
    copy_to_non_po_invoice
    migrate_dlrm_provider_name  
  end


  def copy_roles_to_po_and_non_po_invoice
    # Migrate invoice reviewers and roles  to po_invoice_roles
    old_invoice_roles = [UserRole.id_for(:invoice_initiator), UserRole.id_for(:invoice_reviewer), UserRole.id_for(:invoice_auditor)]

    new_roles = [UserRole.id_for(:po_invoice_initiator), UserRole.id_for(:po_invoice_reviewer), UserRole.id_for(:po_invoice_auditor), UserRole.id_for(:non_po_invoice_initiator), UserRole.id_for(:non_po_invoice_reviewer), UserRole.id_for(:non_po_invoice_auditor)]
    Policy.joins(:company).with_application("vp").each do |policy|
      policy.policy_user_roles.where(user_role_id: old_invoice_roles).each do |pur|
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



  def copy_to_po_invoice
    reviewal_levels = ReviewalLevel.unscoped.where(associated_entity_type: 'InvoiceProvider')
    reviewal_levels.each do |reviewal_level|
      new_reviewal_level = reviewal_level.dup
      new_reviewal_level.associated_entity_type = "PoInvoiceProvider"
      if new_reviewal_level.save!
        lrms = reviewal_level.level_reviewer_mappings
        lurms = reviewal_level.level_user_reviewer_mappings
      end

      lrms.each do |lrm|
        new_lrm = lrm.dup
        new_lrm.level_id = new_reviewal_level.id
        new_lrm.save!
      end

      lurms.each do |lurm|
        new_lurm  = lurm.dup
        new_lurm.level_id = new_reviewal_level.id
        new_lurm.save!
      end
    end
  end



  def copy_to_non_po_invoice
    reviewal_levels = ReviewalLevel.unscoped.where(associated_entity_type: 'InvoiceProvider')
    reviewal_levels.each do |reviewal_level|
      new_reviewal_level = reviewal_level.dup
      new_reviewal_level.associated_entity_type = "NonPoInvoiceProvider"
      if new_reviewal_level.save!
        lrms = reviewal_level.level_reviewer_mappings
        lurms = reviewal_level.level_user_reviewer_mappings
      end

      lrms.each do |lrm|
        new_lrm = lrm.dup
        new_lrm.level_id = new_reviewal_level.id
        new_lrm.save!
      end

      lurms.each do |lurm|
        new_lurm  = lurm.dup
        new_lurm.level_id = new_reviewal_level.id
        new_lurm.save!
      end
    end
  end


  def migrate_dlrm_provider_name
    Invoice.find_each do |invoice|
      if invoice.procurement.present? && invoice.procurement.purchase_order.present?
        invoice.document_level_reviewer_mappings.update_all(provider_name: 'PoInvoiceProvider')
      else
        invoice.document_level_reviewer_mappings.update_all(provider_name: 'NonPoInvoiceProvider')
      end
    end
  end

end
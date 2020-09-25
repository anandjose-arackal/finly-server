module SearchIndex::Concerns::AccessControl

  ROLE_MAP = {
      vp: {
          admin_access: %i(admin auditor),
          documents_access: {
              purchase_requests: {
                  policy_access: %i(purchase_request_auditor purchaser),
                  collaborators_access: %i(purchase_request_initiator purchase_request_reviewer)
              },
              purchase_orders: {
                  policy_access: %i(purchaser purchase_order_auditor),
                  collaborators_access: %i(purchase_order_initiator purchase_order_reviewer)
              },
              receipt_notes: {
                  policy_access: %i(),
                  collaborators_access: %i()
              },
              invoices: {
                  policy_access: %i(invoice_auditor non_po_invoice_auditor po_invoice_auditor),
                  collaborators_access: %i(invoice_initiator invoice_reviewer non_po_invoice_initiator non_po_invoice_reviewer po_invoice_initiator po_invoice_reviewer non_po_initiator)
              },
              utility_bills: {
                  policy_access: %i(),
                  collaborators_access: %i(utility_bill_initiator utility_bill_reviewer)
              },
              upcoming_invoices: {
                  policy_access: %i(agreement_invoice_auditor),
                  collaborators_access: %i(agreement_invoice_initiator agreement_invoice_reviewer)
              },
              payment_tickets: {
                  policy_access: %i(creditor bank_payment_request_auditor bank_payment_request_creditor),
                  collaborators_access: %i(bank_payment_request_initiator bank_payment_request_reviewer)
              },
              credit_notes: {
                  policy_access: %i(credit_note_auditor),
                  collaborators_access: %i(credit_note_initiator credit_note_reviewer)
              },
              vendors: {
                  policy_access: %i(vendor_manager vendor_auditor),
                  collaborators_access: %i(vendor_creator vendor_reviewer)
              },
              items: {
                  full_access: %i(item_master_manager inventory_manager),
                  policy_access: %i(),
                  collaborators_access: %i()
              },
              agreements: {
                  policy_access: %i(payment_agreement_auditor),
                  collaborators_access: %i(payment_agreement_initiator payment_agreement_reviewer)
              },
              utility_subscriptions: {
                  policy_access: %i(),
                  collaborators_access: %i(utility_bill_master_initiator utility_bill_master_reviewer)
              },
          }
      }
  }

  DRAFT_STATUS = %i(draft open)

  # AC -> AccessControl
  def vp_search_index_ac
    filters = []

    # Do not filter
    ROLE_MAP[:vp][:admin_access].each do |admin_role|
      if has_permission?(admin_role)
        DRAFT_STATUS.each do |status|
          filters << "status_name != #{status}"
        end
        return "(#{filters.join(" AND ")}) OR (collaborators_ids = #{id})"
      end
    end


    ROLE_MAP[:vp][:documents_access].each do |document_name, access|
      if access[:full_access]
        # Do nothing
      else
        if access[:policy_access].present?
          policies = []
          policy_user_roles.each do |role|
            access[:policy_access].each do |policy_role|
              next unless UserRole.id_for(policy_role) == role.user_role_id

              policies << role.policy_id
            end
          end
          filters << "(record_type = #{document_name} AND (#{policies.map { |policy_id| "policy_id = #{policy_id}" }.join(" OR ")}))" if policies.present?
        end

        if access[:collaborators_access].present?
          access[:collaborators_access].each do |collaborator_role|
            next unless has_permission?(collaborator_role)

            filters << "(record_type = #{document_name} AND collaborators_ids = #{id})"
            break
          end
        end
      end
    end
  end

end
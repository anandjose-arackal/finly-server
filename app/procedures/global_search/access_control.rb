class GlobalSearch::AccessControl

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
  TOKEN_EXPIRY = 3.hours

  # AC -> AccessControl
  def self.config_for(user)

    filters = []
    if user.has_permission?(ROLE_MAP[:vp][:admin_access])
      # If user is admin, then show him all records except the ones in draft and open state for the ones which
      # were not created by the user

      # Created by admin
      filters << {collaborators_ids: user.id}

      # All records not in draft State
      filters << {status_name: {not: DRAFT_STATUS}}
    else
      ROLE_MAP[:vp][:documents_access].each do |document_name, access|
        if access[:full_access].present? and user.has_permission?(access[:full_access])
          filters  << {record_type: document_name}
        else
          if access[:policy_access].present? and user.has_permission?(access[:policy_access])
            policies = []
            user.policy_user_roles.each do |role|
              access[:policy_access].each do |policy_role|
                next unless UserRole.id_for(policy_role) == role.user_role_id

                policies << role.policy_id
              end
            end
            filters << {_and: [{record_type: document_name}, {policy_id: policies}]}
          end

          if access[:collaborators_access].present? and user.has_permission?(access[:collaborators_access])
            access[:collaborators_access].each do |collaborator_role|
              next unless user.has_permission?(collaborator_role)

              filters << {record_type: document_name, collaborator_role: user.id}
              break
            end
          end
        end
      end
    end

    return nil if filters.blank?

    config = {_and: [{_or: filters}, {company_id: user.company_id}]}.to_json

    token = SecureRandom.hex(32)
    redis = Rails.configuration.redis
    redis.set(token, config)
    redis.expire(token, TOKEN_EXPIRY)

    token
  end

end
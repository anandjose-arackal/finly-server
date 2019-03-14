class Procurements::Invoices::Show < Procurements::Invoices::Base
  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
  end

  def validate
    return if record_not_present
    validate_association
  end

  def success
    params[:invoice] = self.invoice
    Procurements::Invoices::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice, :actions, :departments, :sub_departments, :cost_centers, :reviewal_chains, :policies,
                  :tax_rates, :locations, :budgets

    def init
      self.invoice = params[:invoice]
      self.departments = user.company.departments.roots

      self.locations = user.company.locations
      if invoice.created_by.departments.present?
        self.sub_departments = invoice.created_by.departments.only_sub_departments
      else
        self.sub_departments = invoice.created_by.company.departments.only_sub_departments
      end
      self.cost_centers = user.company.cost_centers
      self.tax_rates = user.company.tax_rates

      # policy_ids = invoice.created_by.policy_user_mappings.exclude_deleted.pluck(:policy_id)
      # self.policies = user.company.policies.with_id(policy_ids).with_application(:vp)
      params[:filter_role_id] = [UserRole.id_for(:invoice_initiator)]
      self.policies = Policy::VendorPayments::Index.(user, params).policies rescue Invoice.none

      self.reviewal_chains = []

      self.actions = get_actions

      if self.invoice.items.present?
        op = BudgetsCalculator::RelevantBudgets.(user, object: self.invoice)
        if op.success?
          self.budgets = op.budget_data
        end
      end

      params[:reviewal_document] = invoice

      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }

        self.reviewal_chains.push(chain)
      end
    end

    def get_actions
      actions = {}
      actions[:audit_trail] = true
      actions[:export_items] = true

      if self.invoice.items.count > 0
        actions[:show_comments] = true
      end

      if document_owner? && (self.invoice.open? || self.invoice.retracted? || self.invoice.rejected?)
        actions[:policy_editable] = get_policy_editable
        actions[:approval_chain_editable] = true
        actions[:submit] = {
            url: Rails.application.routes.url_helpers.procure_inward_invoice_submit_path(inward_invoice_id: invoice.id),
            method: "PUT"
        }

        actions[:delete] = {
            url: Rails.application.routes.url_helpers.procure_inward_invoice_path(id: invoice.id),
            method: "DELETE"
        }

        actions[:update] = {
              url: Rails.application.routes.url_helpers.bank_transfer_inward_invoice_path(id: invoice.id),
              method: "PUT"
          }
        actions[:document_editable] = true
      end

      if invoice.approved? || invoice.auto_approved? || invoice.unpaid? || invoice.partially_paid? || invoice.paid?
        if user_in_level? || document_owner?
          # actions[:close] = {
          #     url: Rails.application.routes.url_helpers.procure_inward_invoice_close_path(inward_invoice_id: invoice.id),
          #     method: "PUT"
          # }
        end

        if (user_in_level? && user.vendor_payment_creditor?) || user.vendor_payment_creditor?
          actions[:make_payment] = true
        end

        actions[:document_editable] = false
        # actions[:download] = true
      end

      if invoice.processing?
        if user_in_level?
          actions[:approve] = {
              url: Rails.application.routes.url_helpers.procure_inward_invoice_approve_path(inward_invoice_id: invoice.id),
              method: "PUT"
          }
          actions[:reject] = {
              url: Rails.application.routes.url_helpers.procure_inward_invoice_reject_path(inward_invoice_id: invoice.id),
              method: "PUT"
          }

          actions[:update] = {
              url: Rails.application.routes.url_helpers.bank_transfer_inward_invoice_path(id: invoice.id),
              method: "PUT"
          }
          actions[:document_editable] = true
          actions[:policy_editable] = false
          actions[:approval_chain_editable] = false
        end

        if document_owner?
          actions[:retract] = {
              url: Rails.application.routes.url_helpers.procure_inward_invoice_retract_path(inward_invoice_id: invoice.id),
              method: "PUT"
          }

          actions[:document_editable] = false
        end
      end


      actions
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      op.chain
    end

    def document_owner?
      invoice.created_by_user_id == user.id
    end

    def get_policy_editable
      if invoice.procurement&.purchase_order.present?
        false
      else
        true
      end
    end

    def get_approval_policy_editable

    end

    def user_in_level?
      current_level = invoice.level
      amount = invoice&.net_amount&.value || 0

      if current_level.present?
        if current_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include? user.id
          return true
        end
      end

      false
    end
  end

  def validate_presence
    if invoice.blank?
      add_message :error, 'Record not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_association
    # Validate of current user is owner of PO
    return if invoice.validate_if_owner(user)
    return if invoice.validate_if_admin(user)
    return if invoice.validate_if_reviewer(user)
    raise_unauthorized_exception
  end

end
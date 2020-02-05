class Procurements::Invoices::Show < Procurements::Invoices::Base
  attr_accessor :invoice

  def init
    invoice_id = params[:id] || params[:invoice_id] || params[:inward_invoice_id]
    self.invoice = user.company.inward_invoices.find_by id: invoice_id
  end

  def validate
    return if record_not_present
    validate_document_access
  end

  def success
    params[:invoice] = self.invoice
    Procurements::Invoices::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::Invoices::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :invoice, :actions, :departments, :sub_departments, :cost_centers, :reviewal_chains, :policies,
                  :tax_rates, :locations, :budgets, :gstin_locations, :variable_periodic_invoice, :bank_payment_request_policies

    def init
      self.invoice = params[:invoice]
      # self.departments = user.company.departments.roots
      # self.departments = user.company.departments

      # self.locations = user.company.locations
      params[:filter_role_id] =  invoice.get_invoice_provider_name == 'PoInvoiceProvider' ? [UserRole.id_for(:po_invoice_initiator)] : [UserRole.id_for(:non_po_invoice_initiator)]
      # params[:filter_role_id] = [UserRole.id_for(:invoice_initiator)]
      self.departments = Company::Departments::Index.(invoice.created_by, params).policy_department_filter_mapping&.leaves
      self.locations = Company::Locations::Index.(invoice.created_by, params).policy_location_filter_mapping&.leaves

      if invoice.created_by&.departments.present?
        self.sub_departments = invoice.created_by.departments.only_sub_departments
      else
        self.sub_departments = invoice.created_by.company.departments.only_sub_departments
      end
      self.cost_centers = user.company.cost_centers.non_deleted
      self.tax_rates = user.company.tax_rates
      self.gstin_locations = self.invoice.vendor&.gstin_locations
      self.variable_periodic_invoice = (self.invoice.open? || self.invoice.rejected? || self.invoice.retracted?) && (self.invoice.billing_type_id == BillingType.id_for(:variable_periodic))

      # policy_ids = invoice.created_by.policy_user_mappings.exclude_deleted.pluck(:policy_id)
      # self.policies = user.company.policies.with_id(policy_ids).with_application(:vp)
      # params[:filter_role_id] = [UserRole.id_for(:invoice_initiator)]
      self.policies = Policy::VendorPayments::Index.(invoice.created_by, params).policies rescue Policy.none

      params[:filter_role_id] = [UserRole.id_for(:bank_payment_request_initiator)]
      self.bank_payment_request_policies = Policy::VendorPayments::Index.(user, params).policies rescue Policy.none


      self.actions = get_actions

      if self.invoice.items.present?
        op = BudgetsCalculator::RelevantBudgets.(user, object: self.invoice)
        if op.success?
          self.budgets = op.budget_data
        end
      end

      if self.invoice.created_by_user_id == user.id && Invoice.status_ids(:open, :retracted, :rejected).include?(self.invoice.invoice_status_id)
        self.reviewal_chains = []
        params[:reviewal_document] = invoice
        params[:provider_name] = get_invoice_provider_name
        policies.each do |policy|
          params[:policy_id] = policy.id
          chain = {
              policy_id: policy.id,
              reviewal_chain: get_reviewal_chain
          }

          self.reviewal_chains.push(chain)
        end
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
      # params[:provider_name] = invoice.get_invoice_provider_name
      params[:provider_name] = get_invoice_provider_name
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
      # current_level = invoice.level
      # amount = invoice&.net_amount&.value || 0

      # if current_level.present?
        # if current_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include? user.id
        #   return true
        # end
      # end
      provider_name = invoice.get_invoice_provider_name
      invoice.get_reviewers(nil, provider_name).include?(user)
    end
  
    def get_invoice_provider_name
      if self.invoice.procurement.purchase_order.present?
        return 'PoInvoiceProvider'
      elsif self.invoice.payment_agreement_id.present?
        return 'AgreementInvoiceProvider'
      else
        return 'NonPoInvoiceProvider'
      end
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

  def validate_document_access
    # This will be refactored when Non-po initiator/reviewer will be in place i.e. po and non-po invoice can have different policy

    # Validate of current user is owner of PO
    return if invoice.validate_if_owner(user)
    return if invoice.validate_if_admin(user)
    return if invoice.validate_if_reviewer(user) # For DLRMS reviewers

    # Validate  Po invoice auditor role
    if invoice.procurement.present? && invoice.procurement.purchase_order.present?
      return if  invoice.validate_if_po_invoice_auditor(user)
      return if  invoice.validate_if_po_invoice_reviewer(user)
    end

    if invoice.procurement.blank? || invoice.procurement.purchase_order.blank?
      return if invoice.validate_if_non_po_invoice_auditor(user)
      return if invoice.validate_if_non_po_invoice_reviewer(user)
    end

    # Validate Non po invoice auditor role


    # Validation for Po invoice
    # return unless po_invoice_reviewer
    # return unless po_invoice_auditor

    # Validation for non po invoice
    # return unless non_po_invoice_reviewer
    # return unless non_po_invoice_auditor

    # Need to check dlrms as above conditions are breaking
    #Quick fix
    # Removing this as we now have non and non po invoice role
    # return if user.is_invoice_reviewer?
    # return if user.is_invoice_auditor?
    
    return if user.is_bank_payment_request_initiator?
    return if user.is_bank_payment_request_reviewer?
    return if user.is_bank_payment_request_creditor?
    return if user.is_credit_note_initiator?
    return if user.is_credit_note_reviewer?
    return if user.is_agreement_invoice_initiator? || user.is_agreement_invoice_reviewer? || user.is_agreement_invoice_auditor?
    # Jugaad because invoice show, po show, inward doc show.. all are on procurement show. So if one has access to one document , he will have access to all documents as all documents are being shown
    # return if validate_po_access
    add_message :error, 'You are not authorized to view this document, Please contact your Admin.'
  end

  def validate_po_access
    po_params = params
    po_params["id"] = invoice.procurement.purchase_order.id rescue nil
    Procurements::PurchaseOrders::Show.(user, po_params).success? if po_params["id"].present?
  end


  def po_invoice_reviewer
  end

  def po_invoice_auditor
  end

  def non_po_invoice_reviewer
  end

  def non_po_invoice_auditor
  end

end
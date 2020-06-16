class Dashboard::VendorPayments::Configs < Dashboard::VendorPayments::Base
  attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

  def init
    self.departments = Company::Departments::Index.(user, params).policy_department_filter_mapping
    self.policies = Policy::VendorPayments::Index.(user, params).policies
    self.locations = Company::Locations::Index.(user, params).policy_location_filter_mapping
    self.request_types = {
        awaiting_action: false,
        payment_tickets: false,
        purchase_requests: false,
        purchase_orders: false,
        non_po_invoices: false,
        po_invoices: false,
        agreement_invoices: false,
        budgets: false,
        po_advances: false,
        grns: false,
        vendors: false,
        payment_agreements: false,
        approved_purchase_request_items: false,
        utility_bill_masters: false,
        utility_bills: false
    }

    reviewer_role_ids = UserRole.ids_for(:admin, :purchase_request_reviewer, :purchase_order_reviewer, :non_po_invoice_reviewer, :po_invoice_reviewer, :agreement_invoice_reviewer, :vendor_reviewer, :bank_payment_request_reviewer, :payment_agreement_reviewer, :utility_bill_master_reviewer, :utility_bill_reviewer)

    if user.vendor_payments_admin?
      request_types.keys.map {|key| request_types[key] = true }
      unless user.company.procurement_enabled?
        request_types[:po_advances] = false
        request_types[:purchase_orders] = false
        request_types[:po_invoices] = false
        request_types[:non_po_invoices] = false
        request_types[:agreement_invoices] = false
        request_types[:grns] = false
      end

      # Disabled vendors as the card was not providing any useful information
      request_types[:vendors] = false
      unless user.company.vendor_empanelment_workflow_enabled?
        request_types[:vendors] = false
      end

      request_types[:approved_purchase_request_items] = false
      unless user.company.purchase_requisition_enabled?
        request_types[:purchase_requests] = false
        request_types[:approved_purchase_request_items] = false
      end

      request_types[:payment_agreements] = false
      unless user.company.agreement_based_payment_system_enabled?
        request_types[:payment_agreements] = false
        request_types[:agreement_invoices] = false
      end

      request_types[:utility_bill_masters] = false
      unless user.company.utility_bills_enabled?
        request_types[:utility_bill_masters] = false
        request_types[:utility_bills] = false
      end
    else
      if user.enforce_policy_enabled?
        user_roles = user.policy_user_roles.joins(:policy).where({policies: {default: false}}).pluck('policy_user_roles.user_role_id').uniq
      else
        user_roles = user.policy_user_roles.pluck(:user_role_id).uniq
      end
      user_roles.each do |role_id|
        if reviewer_role_ids.include?(role_id)
          request_types[:awaiting_action] = true
        end
        case role_id
        when UserRole.id_for(:purchase_request_initiator)
          request_types[:purchase_requests] = true
        when UserRole.id_for(:purchase_order_initiator)
          request_types[:purchase_orders] = true
          request_types[:approved_purchase_request_items] = true
        when UserRole.id_for(:goods_receiver)
          request_types[:grns] = true
        when UserRole.id_for(:po_invoice_initiator)
          request_types[:po_invoices] = true
          request_types[:invoices] = true
        when UserRole.id_for(:non_po_invoice_initiator)
          request_types[:non_po_invoices] = true
          request_types[:invoices] = true
        when UserRole.id_for(:agreement_invoice_initiator)
          request_types[:non_po_invoices] = true
          request_types[:invoices] = true
        when UserRole.id_for(:bank_payment_request_initiator)
          request_types[:payment_tickets] = true
        when UserRole.id_for(:bank_payment_request_creditor)
          request_types[:payment_tickets] = true
          if user.company.procurement_enabled?
            request_types[:po_advances] = true
          end
        when UserRole.id_for(:payment_agreement_initiator), UserRole.id_for(:agreement_invoice_initiator)
          request_types[:payment_agreements] = true
        when UserRole.id_for(:inventory_manager)
          request_types[:approved_purchase_request_items] = true
        when UserRole.id_for(:utility_bill_master_initiator)
          request_types[:utility_bill_masters] = true
        when UserRole.id_for(:utility_bill_initiator)
          request_types[:utility_bills] = true
        end
      end
    end
    
    unless user.company.feature_subscription.grn_enabled || user.company.feature_subscription.srn_enabled
      request_types[:grns] = false
    end

  end

  def success
    params[:departments] = self.departments
    params[:request_types] = self.request_types
    params[:policies] = self.policies
    params[:locations] = self.locations
    Dashboard::VendorPayments::Configs::DashboardPresenter.new(user, params, messages)
  end

  class Dashboard::VendorPayments::Configs::DashboardPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

    has_scope :filter_status_id
    has_scope :filter_user_id
    has_scope :filter_only_roots

    def init
      self.departments = apply_scopes(params[:departments], {filter_only_roots: true})
      self.sub_departments = params[:departments].only_sub_departments rescue Department.none
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.request_types = params[:request_types]
    end
  end
end
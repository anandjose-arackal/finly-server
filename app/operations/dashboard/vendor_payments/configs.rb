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
      budgets: false,
      po_advances: false,
      grns: false,
      vendors: false
    }

    reviewer_role_ids = UserRole.ids_for(:admin, :purchase_request_reviewer, :purchase_order_reviewer, :invoice_reviewer, :vendor_reviewer, :bank_payment_request_reviewer)

    if user.vendor_payments_admin?
      request_types.keys.map {|key| request_types[key] = true }
      unless user.company.procurement_enabled?
        request_types[:po_advances] = false
        request_types[:purchase_orders] = false
        request_types[:po_invoices] = false
        request_types[:non_po_invoices] = false
        request_types[:grns] = false
      end

      unless user.company.vendor_empanelment_workflow_enabled?
        request_types[:vendors] = false
      end

      unless user.company.purchase_requisition_enabled?
        request_types[:purchase_requests] = false
      end
    else
      user_roles = user.policy_user_roles.pluck(:user_role_id).uniq
      user_roles.each do |role_id|
        if reviewer_role_ids.include?(role_id)
          request_types[:awaiting_action] = true
        end

        case role_id
        # when UserRole.id_for(:admin) ########## Admin role check removed as PUR usually doesn't contain admin role
        #   request_types.keys.map {|key| request_types[key] = true }
        #   break
        when UserRole.id_for(:purchase_request_initiator)
          request_types[:purchase_requests] = true
        when UserRole.id_for(:purchase_order_initiator)
          request_types[:purchase_orders] = true
        when UserRole.id_for(:goods_receiver)
          request_types[:grns] = true
        when UserRole.id_for(:invoice_initiator)
          request_types[:po_invoices] = true
          request_types[:non_po_invoices] = true
        when UserRole.id_for(:bank_payment_request_initiator)
          request_types[:payment_tickets] = true
        when UserRole.id_for(:bank_payment_request_creditor)
          request_types[:payment_tickets] = true
          if user.company.procurement_enabled?
            request_types[:po_advances] = true
          end
        # when UserRole.id_for(:vendor_creator)
        #   if user.company.vendor_empanelment_workflow_enabled?
        #     request_types[:vendors] = true
        #   end
        end
      end
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
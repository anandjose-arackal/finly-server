class Dashboard::VendorPayments::Configs < Dashboard::VendorPayments::Base
  attr_accessor :departments, :sub_departments, :request_types, :policies, :locations

  def init
    self.departments = Company::Departments::Index.(user, params).departments
    self.policies = Policy::VendorPayments::Index.(user, params).policies
    self.locations = user.company.locations
    self.request_types = {
      awaiting_action: false,
      payment_tickets: false,
      purchase_reqeusts: false,
      purchase_orders: false,
      non_po_invoices: false,
      po_invoices: false,
      budgets: false,
      po_advances: false,
      grns: false,
      vendors: false
    }

    user_roles = user.policy_user_roles.pluck(:user_role_id).uniq
    reviewer_role_ids = UserRole.ids_for(:admin, :purchase_request_reviewer, :purchase_order_reviewer, :invoice_reviewer, :vendor_reviewer, :bank_payment_request_reviewer)

    user_roles.each do |role_id|

      if reviewer_role_ids.include?(role_id)
        request_types[:awaiting_action] = true
      end

      case role_id
      when UserRole.id_for(:admin)
        request_types.keys.map {|key| request_types[key] = true }
        break
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
        request_types[:po_advances] = true
      when UserRole.id_for(:vendor_reviewer)
        if user.company.vendor_empanelment_workflow_enabled?
          request_types[:vendors] = true
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
      self.sub_departments = params[:departments].only_sub_departments
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.policies = params[:policies]
      self.locations = params[:locations]
      self.request_types = params[:request_types]
    end
  end
end
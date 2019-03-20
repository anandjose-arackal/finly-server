class Procurements::PurchaseOrders::Show < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :policies
  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    return if record_not_present
    validate_document_access
  end

  def process
    if self.purchase_order.po_number.blank?
      op = Procurements::DocumentNumbers::Generate.(user, {document: self.purchase_order})
      if op.success?
        self.purchase_order.po_number = op.document_number
      end
    end
  end

  def success
    params[:purchase_order] = self.purchase_order
    Procurements::PurchaseOrders::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order, :actions, :reviewal_chains, :policies, :departments, :budgets, :cost_centers,
                  :sub_departments, :tax_rates, :locations, :taxes_applicable_flag, :procurement

    def init
      self.purchase_order = params[:purchase_order]
      self.procurement = self.purchase_order.procurement
      self.actions = get_actions
      self.departments = user.company.departments.roots
      self.locations = user.company.locations

      if purchase_order.user.departments.present?
        self.sub_departments = purchase_order.user.departments.only_sub_departments
      else
        self.sub_departments = purchase_order.user.company.departments.only_sub_departments
      end
      self.cost_centers = user.company.cost_centers
      self.tax_rates = user.company.tax_rates

      # policy_ids = purchase_order.user.policy_user_mappings.exclude_deleted.pluck(:policy_id)
      # self.policies = user.company.policies.with_id(policy_ids).with_application(:vp)
      params[:filter_role_id] = [UserRole.id_for(:purchase_order_initiator)]
      self.policies = Policy::VendorPayments::Index.(user, params).policies rescue PurchaseOrder.none

      # Show taxes as applicable in the pdf based on this
      self.taxes_applicable_flag = taxes_applicable_flag?

      self.reviewal_chains = []
      params[:reviewal_document] = purchase_order

      policies.each do |policy|
        params[:policy_id] = policy.id
        chain = {
            policy_id: policy.id,
            reviewal_chain: get_reviewal_chain
        }
        self.reviewal_chains.push(chain)
      end

      if purchase_order.items.present?
        op = BudgetsCalculator::RelevantBudgets.(user, object: self.purchase_order)
        if op.success?
          self.budgets = op.budget_data
        end
      end
    end

    def get_actions
      actions = {}

      actions[:audit_trail] = true
      actions[:export_items] = true
      if purchase_order.items.count > 0
        actions[:show_comments] = true
      end



      if document_owner? && (self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?)
        actions[:submit] = {url: Rails.application.routes.url_helpers.procure_purchase_order_submit_path(purchase_order_id: purchase_order.id),method: "PUT"}
        actions[:save] = {url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),method: "PUT"}
        actions[:delete] = {url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id), method: "DELETE"}
        actions[:policy_editable] = true
        actions[:document_editable] = true
        actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
      end

      if purchase_order.approved? || purchase_order.auto_approved?
        if user_in_level? || document_owner?
          actions[:send_mail] = {url: Rails.application.routes.url_helpers.procure_configs_send_mail_path, method: "POST"}
          actions[:mark_send_to_vendor] = {url: Rails.application.routes.url_helpers.procure_purchase_order_mark_send_to_vendor_path(purchase_order_id: purchase_order.id), method: "PUT"}

          # todo
          if purchase_order.can_unapprove?(user)
            actions[:unapprove] = {url: Rails.application.routes.url_helpers.procure_purchase_order_unapprove_path(purchase_order_id: purchase_order.id), method: "PUT"}
          end
          actions[:close] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_close_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }

          actions[:document_editable] = false
        end

        if user.vendor_payment_admin? || user.vendor_payment_finance?
          actions[:make_advance_payment] = {url: Rails.application.routes.url_helpers.procure_purchase_order_make_advance_payment_path(purchase_order_id: purchase_order.id),method: "PUT"}
        end
        actions[:download] = true
      end

      if purchase_order.sent_to_vendor?
        if user_in_level? || document_owner?
          actions[:po_revision] = {url: Rails.application.routes.url_helpers.procure_purchase_order_create_po_revisions_path(purchase_order_id: purchase_order.id), method: "GET"}
          actions[:close] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_close_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }
        end

        if self.procurement.po_revisions.pluck(:revision_of_id).include? self.purchase_order.id
          actions[:original_po_blocked] = true
        end
      end

      if PurchaseOrderStatus.status_ids_for_voidable.include? purchase_order.purchase_order_status_id
        if user.vendor_payment_admin?
          actions[:void] = {url: Rails.application.routes.url_helpers.procure_purchase_order_void_path(purchase_order_id: purchase_order.id),method: 'PUT'}
        end
      end

      if purchase_order.processing?
        if user_in_level?
          actions[:approve] = {url: Rails.application.routes.url_helpers.procure_purchase_order_approve_path(purchase_order_id: purchase_order.id),method: "PUT"}
          actions[:reject] = {url: Rails.application.routes.url_helpers.procure_purchase_order_reject_path(purchase_order_id: purchase_order.id),method: "PUT"}
          actions[:save] = {url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),method: "PUT"}
          actions[:document_editable] = true
          actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
        end
        if purchase_order.can_unapprove?(user)
            actions[:unapprove] = {url: Rails.application.routes.url_helpers.procure_purchase_order_unapprove_path(purchase_order_id: purchase_order.id), method: "PUT"}
        end
        if document_owner?
          actions[:retract] = {url: Rails.application.routes.url_helpers.procure_purchase_order_retract_path(purchase_order_id: purchase_order.id),method: "PUT"}
          actions[:remind] = {url: Rails.application.routes.url_helpers.procure_purchase_order_remind_path(purchase_order_id: purchase_order.id),method: "PUT"}
          actions[:document_editable] = false
          actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
        end
      end

      if user.vendor_payment_admin?
        unless purchase_order.voided?
          actions[:policy_editable] = true
          actions[:document_editable] = true
          actions[:save] = {url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),method: "PUT"}
          actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
        end
      end

      actions
    end

    def get_reviewal_chain
      op = ::ReviewalManager::ReviewalChain.(user, params)
      op.chain
    end

    def document_owner?
      purchase_order.user_id == user.id
    end

    def taxes_applicable_flag?
      # Shows "Taxes as applicable" text on pdf if true
      flag = false
      self.purchase_order.items.each do |item|
        if item.tax_rate.blank? || item.tax_rate&.rate == 0
          flag = true
          break
        end
      end
      flag
    end

    def user_in_level? # todo put document level reviewer mapping here
      current_level = purchase_order.level
      amount = purchase_order&.balance_amount&.value || 0

      if current_level.present?
        if current_level.level_reviewer_mappings.with_threshold(amount).pluck(:reviewer_id).include? user.id
          return true
        end
      end

      false
    end
  end

  def validate_presence
    if purchase_order.blank? || (purchase_order.company_id != user.company_id)
      add_message :error, 'Record not found'
      return false
    end
    true
  end

  def record_not_present
    !validate_presence
  end

  def validate_document_access
    # Validate of current user is owner of PO
    return if purchase_order.validate_if_owner(user)
    return if purchase_order.validate_if_admin(user) && (!purchase_order.open? || purchase_order.user_id == user.id)
    return if purchase_order.validate_if_reviewer(user)
    raise_unauthorized_exception
  end
end
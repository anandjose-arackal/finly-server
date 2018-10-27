class Procurements::PurchaseOrders::Show < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :policies
  def init
    purchase_order_id = params[:id] || params[:purchase_order_id]
    self.purchase_order = user.company.purchase_orders.find_by id: purchase_order_id
  end

  def validate
    unless self.purchase_order.present?
      add_message :error, 'Purchase Order not Found'
    end
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
                  :sub_departments, :tax_rates, :locations

    def init
      self.purchase_order = params[:purchase_order]
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

      self.policies = purchase_order.user.policies.with_application(:vp)

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
      if purchase_order.items.count > 0
        actions[:show_comments] = true
      end

      if document_owner? && (self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?)
        actions[:submit] = {
            url: Rails.application.routes.url_helpers.procure_purchase_order_submit_path(purchase_order_id: purchase_order.id),
            method: "PUT"
        }
        actions[:save] = {
            url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),
            method: "PUT"
        }
        actions[:delete] = {
            url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),
            method: "DELETE"
        }
        actions[:policy_editable] = true
        actions[:document_editable] = true
        actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
      end

      if purchase_order.approved? || purchase_order.auto_approved?
        if user_in_level? || document_owner?
          actions[:send_mail] = {
              url: Rails.application.routes.url_helpers.procure_configs_send_mail_path,
              method: "POST"
          }
          # actions[:close] = {
          #     url: Rails.application.routes.url_helpers.procure_purchase_order_close_path(purchase_order_id: purchase_order.id),
          #     method: "PUT"
          # }
          actions[:document_editable] = false
        end
        actions[:download] = true
      end

      if PurchaseOrderStatus.status_ids_for_voidable.include? purchase_order.purchase_order_status_id
        if user.vendor_payment_admin? || document_owner?
          actions[:void] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_void_path(id: purchase_order.id),
              method: 'PUT'
          }
        end
      end

      if purchase_order.processing?
        if user_in_level?
          actions[:approve] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_approve_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }
          actions[:reject] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_reject_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }
          actions[:save] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),
              method: "PUT"
          }
          actions[:document_editable] = true
          actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
        end
        if document_owner?
          actions[:retract] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_retract_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }
          actions[:remind] = {
              url: Rails.application.routes.url_helpers.procure_purchase_order_remind_path(purchase_order_id: purchase_order.id),
              method: "PUT"
          }
          actions[:document_editable] = false
          actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
        end
      end

      if user.vendor_payment_admin?
        actions[:document_editable] = true
        actions[:save] = {
            url: Rails.application.routes.url_helpers.procure_purchase_order_path(id: purchase_order.id),
            method: "PUT"
        }
        actions[:procurement_terms_editable] = user.permission.edit_terms_within_po
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
end
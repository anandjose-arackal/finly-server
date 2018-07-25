class Procurements::PurchaseOrders::Show < Procurements::PurchaseOrders::Base
  attr_accessor :purchase_order, :policies
  def init
    purchase_order_id = params[:id] || params[:purchase_order_params]
    self.purchase_order = PurchaseOrder.find_by id: purchase_order_id
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
        self.po_number = op.document_number
      end
    end
  end

  def success
    params[:purchase_order] = self.purchase_order
    Procurements::PurchaseOrders::Show::ShowPresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::Show::ShowPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :purchase_order, :actions, :chain_of_approvals

    def init
      self.purchase_order = params[:purchase_order]
      self.actions = get_actions
      self.chain_of_approvals = get_chain_of_approvals
      # self.policies =
    end

    def get_actions
      actions = {}


      if document_owner? && (self.purchase_order.open? || self.purchase_order.retracted? || self.purchase_order.rejected?)
        actions[:submit] = {url: Rails.application.routes.url_helpers.procure_purchase_order_submit_path(purchase_order_id: purchase_order.id)}
      end

      if purchase_order.approved? && (user_in_level? || document_owner?)
        actions[:send_mail] = {url: Rails.application.routes.url_helpers.procure_configs_send_mail_path}
        actions[:close] = {url: Rails.application.routes.url_helpers.procure_purchase_order_close_path(purchase_order_id: purchase_order.id)}
      end

      if user_in_level? && purchase_order.processing?
        actions[:approve] = {url: Rails.application.routes.url_helpers.procure_purchase_order_approve_path(purchase_order_id: purchase_order.id)}
        actions[:reject] = {url: Rails.application.routes.url_helpers.procure_purchase_order_reject_path(purchase_order_id: purchase_order.id)}
      end

      actions
    end

    def get_chain_of_approvals

    end

    def document_owner?
      purchase_order.user_id == user.id
    end

    def user_in_level?
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
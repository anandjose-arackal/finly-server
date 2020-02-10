# this operation will take a bunch of payment request IDs and create a summary of the provided bulk action
# 

class BankTransfer::PaymentRequest::Review::BulkActions < BankTransfer::PaymentRequest::Review::Base

  attr_accessor :bank_payment_requests, :processing_status_id,
                :errors_found, :validate_result, :action, :summary,
                :processable_bank_payment_requests, :unprocessable_bank_payment_requests

  def pre_validate
    super
    return if has_errors?
  end

  def init
    ids = params[:ids] || params[:bank_payment_request_ids] || params[:payment_request_ids]
    unless ids.is_a?(Array)
      ids = ids.split(',')
    end
    self.bank_payment_requests = BankTransfer::PaymentRequest::Index.(user, params).payment_requests.with_id(ids) rescue nil
    self.bank_payment_requests = self.bank_payment_requests.includes_details

    self.action = params[:bulk_action]
  end

  def validate
    if bank_payment_requests.empty?
      add_message :error, "Payment orders not found"
      return
    end

    if self.action.blank? or ['bulk_take_control', 'bulk_reject', 'bulk_approve'].exclude?(self.action)
      add_message :error, "Please select a bulk action."
      return
    end

  end

  def process
    case self.action
    when 'bulk_take_control'
      process_take_control
    when 'bulk_reject'
      process_reject
    when 'bulk_approve'
      process_approve
    end

    self.summary = build_hash
  end

  def success
    params[:summary] = self.summary
    BankTransfer::PaymentRequest::Review::BulkActionsPresenter.new(user, params, messages)
  end

  class BankTransfer::PaymentRequest::Review::BulkActionsPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :summary

    def init
      self.summary  = params[:summary]
    end
  end

  private

  def process_take_control
    unless user.vendor_payment_admin?
      add_message :error, "Only admins can take control of a payment ticket"
      return
    end

    accept_bpr = []
    reject_bpr = []

    self.bank_payment_requests.each do |bank_payment_request|

      valid = false

      if bank_payment_request.can_take_control?
        valid = (user_already_in_control?(bank_payment_request)) ? false : true
      end

      accept_bpr << bank_payment_request.id if valid
      reject_bpr << bank_payment_request.id unless valid

    end
 
    self.processable_bank_payment_requests = self.bank_payment_requests.where(id: accept_bpr)
    self.unprocessable_bank_payment_requests = self.bank_payment_requests.where(id: reject_bpr)
  end

  def process_reject
    accept_bpr = []
    reject_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = (bank_payment_request.can_really_reject?) ? true : false

      accept_bpr << bank_payment_request.id if valid
      reject_bpr << bank_payment_request.id unless valid
    end
 
    self.processable_bank_payment_requests = self.bank_payment_requests.where(id: accept_bpr)
    self.unprocessable_bank_payment_requests = self.bank_payment_requests.where(id: reject_bpr)
  end

  def process_approve
    accept_bpr = []
    reject_bpr = []
    self.bank_payment_requests.each do |bank_payment_request|
      valid = (bank_payment_request.can_really_approve?) ? true : false

      accept_bpr << bank_payment_request.id if valid
      reject_bpr << bank_payment_request.id unless valid
    end
 
    self.processable_bank_payment_requests = self.bank_payment_requests.where(id: accept_bpr)
    self.unprocessable_bank_payment_requests = self.bank_payment_requests.where(id: reject_bpr)
  end

  def build_hash
    {
      processable: build_processable,
      un_processable: build_unprocessable,
      selected: build_selected
    }
  end

  def build_processable
    payment_tickets = self.processable_bank_payment_requests
    total_items = payment_tickets.count
    # total_amount = payment_tickets.map {|p| p.requested_amount.value.to_f.round(2)}.compact.sum
    total_amount = payment_tickets.map {|p| p.payment_order&.amount_requested&.value.to_f.round(2)}.compact.sum
    items = []

    payment_tickets.each do |bpr|
      items << {
        id: bpr.id,
        order_name: bpr.name,
        requested_amount: bpr.payment_order&.amount_requested&.value.to_f.round(2),
        status: bpr.status&.name 
      }
    end

    {total_items: total_items, total_amount: total_amount, items: items}
  end

  def build_unprocessable
    payment_tickets = self.unprocessable_bank_payment_requests
    total_items = payment_tickets.count
    # total_amount = payment_tickets.map {|p| p.requested_amount.value.to_f.round(2)}.compact.sum
    total_amount = payment_tickets.map {|p| p.payment_order&.amount_requested&.value.to_f.round(2)}.compact.sum
    items = []

    # FE does not require this for now
    # 
    # payment_tickets.each do |bpr|
    #   items << {
    #     id: bpr.id,
    #     order_name: bpr.name,
    #     requested_amount: bpr.requested_amount&.value.to_f.round(2),
    #     status: bpr.status&.name 
    #   }
    # end

    {total_items: total_items, total_amount: total_amount, items: items}
  end

  def build_selected
    payment_tickets = self.bank_payment_requests
    total_items = payment_tickets.count
    # total_amount = payment_tickets.map {|p| p.requested_amount.value.to_f.round(2)}.compact.sum
    total_amount = payment_tickets.map {|p| p.payment_order&.amount_requested&.value.to_f.round(2)}.compact.sum
    items = []

    # FE does not require this for now
    # 
    # payment_tickets.each do |bpr|
    #   items << {
    #     id: bpr.id,
    #     order_name: bpr.name,
    #     requested_amount: bpr.requested_amount&.value.to_f.round(2),
    #     status: bpr.status&.name 
    #   }
    # end

    {total_items: total_items, total_amount: total_amount, items: items}
  end

  def user_already_in_control?(bank_payment_request)
    # check for the current level if it isn't taken control
    # check if the same user is not taking control twice
    # check if for the same level if any other user has also taken control

    return false if bank_payment_request.dlrms.blank?
    (bank_payment_request.dlrms&.find_by(level_id: bank_payment_request.level&.id).taken_control_by_id == user.id)
  end


end
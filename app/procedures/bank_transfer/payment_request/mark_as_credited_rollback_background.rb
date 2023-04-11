class BankTransfer::PaymentRequest::MarkAsCreditedRollbackBackground < Transactions::API
  
  include Transactions::BackgroundWorker

  sidekiq_options queue: :payments_queue, retry: 0

  step :reset_payment_order_status
    
  def reset_payment_order_status(options, payment_request:, payment_order_status_id:, payment_request_status_id:,controlling_level_id:, **)
    ActiveRecord::Base.transaction do
      payment_request.payment_order.update({payment_order_status_id: payment_order_status_id})
      payment_request.update({status_id: payment_request_status_id, controlling_level_id: controlling_level_id})
    end
  end

end

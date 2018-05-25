# this operation will initiate payments in sidekiq and then credit the entire payment order
# payment by payment because if there are too many the request will go on forever
class BankTransfer::PaymentRequest::Payments::BulkInitiatePayment < BankTransfer::PaymentRequest::Base
  

end
# this operation retries all failed payments inside a payment order
# it will call the payment::retry operation to execute the same

class BankTransfer::PaymentRequest::Retry < BankTransfer::PaymentRequest::Base


end
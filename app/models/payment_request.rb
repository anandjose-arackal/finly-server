# non persistent model that holds info about a particular payment order - things like initiating account,
# receiving account etc.

class PaymentRequest

  attr_accessor :initiating_account_id, :receiving_account_id, :type, :scheduled_on, :synchronous
end
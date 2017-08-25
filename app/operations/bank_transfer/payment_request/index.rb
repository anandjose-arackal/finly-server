# this operation should return the list of payment requests that a particular user
# has access to from the index screen - based on the approval flow logic
# essentially, payment orders that one owns, and payment orders that
class BankTransfer::PaymentRequest::Index < BankTransfer::PaymentRequest::Base

  attr_accessor :role_id

  def pre_validate
    super

  end

  def init

  end

  def process

  end
end
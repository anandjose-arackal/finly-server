# this operation will call the external API for creating a virtual bank account and store it in the db
# can also pass the payment receivable if the request is for a fixed amount for a particular payment receivable

class Invoicing::VirtualBankAccount::Create < Invoicing::VirtualBankAccount::Base

  attr_accessor :account_params

  def init

  end

  private


end
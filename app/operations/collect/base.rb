class Collect::Base < BackgroundOperation

  attr_accessor :virtual_account_transaction, :options

  def self.call(virtual_account_transaction, options = {})
    self.new(virtual_account_transaction, options).run
  end

  def self.call_async(virtual_account_transaction_id, options = {})
    # define the operation to accordingly run the operation in the background
    self.virtual_account_transaction = VirtualAccountTransaction.find_by(id: virtual_account_transaction_id)
    self.new(virtual_account_transaction, options).run
  end

  def initialize(virtual_account_transaction, options = {})
    self.virtual_account_transaction = virtual_account_transaction
    self.options = options
  end

  
end
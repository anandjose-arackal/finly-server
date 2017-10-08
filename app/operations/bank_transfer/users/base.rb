class BankTransfer::Users::Base < BaseOperation

  attr_accessor :company

  def init
    self.company = user.company
  end
end
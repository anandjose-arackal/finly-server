class BankTransfer::AccountOwners::Base < BaseOperation

  def init
    self.company = user.company
  end

end
class BankTransfer::AccountOwners::Count < BankTransfer::AccountOwners::Base

  attr_accessor :count

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def process
    op = BankTransfer::AccountOwners::Index.(user, params)
    if op.success?
      self.count = op.account_owners.count
    else
      add_message :error, op.messages[:error]
    end
  end

  def success
    self.count
  end
end
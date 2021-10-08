class Appsmith::Companies::VirtualBankAccountsController < BaseControllers::AppsmithBase

  def create
    endpoint Appsmith::Companies::VirtualBankAccounts::Ops::Create
  end

end

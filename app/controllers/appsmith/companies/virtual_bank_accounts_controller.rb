class Appsmith::Companies::VirtualBankAccountsController < BaseControllers::AppsmithBase

  layout 'trailblazers', only: [:create]

  def create
    endpoint Appsmith::Companies::VirtualBankAccounts::Ops::Create
  end

end

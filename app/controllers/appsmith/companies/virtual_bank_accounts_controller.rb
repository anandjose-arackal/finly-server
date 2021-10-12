class Appsmith::Companies::VirtualBankAccountsController < BaseControllers::AppsmithBase

  def create
    endpoint Appsmith::Companies::VirtualBankAccounts::Ops::Create
    if @op.success?
      respond response: :success
    else
      respond response: :failure, message: @op[:data]&.messages[:error] || "Unknown Error"
    end
  end
end

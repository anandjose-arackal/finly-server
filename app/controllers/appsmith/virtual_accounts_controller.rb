class Appsmith::VirtualAccountsController < BaseControllers::AppsmithBase

  def create
    endpoint Appsmith::Companies::VirtualAccounts::Create
    if @op.success?
      respond response: :success
    else
      respond response: :failure, message: "Something went wrong generate once again"
    end
  end
end

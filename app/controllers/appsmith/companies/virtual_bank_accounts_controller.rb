class Appsmith::Companies::VirtualBankAccountsController < BaseControllers::AppsmithBase

  def create
    @op = Appsmith::Companies::VirtualBankAccounts::Ops::Create.({params: params.to_unsafe_h, current_user: current_user})
    if @op[:data].success?
      respond response: :success
    else
      respond response: :failure, message: @op[:data].messages[:error]
    end
end
end

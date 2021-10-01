class Appsmith::Companies::VirtualBankAccountsController < BaseControllers::AppsmithBase

    def create
        @result = Appsmith::Companies::VirtualBankAccounts::Create.(current_user,params)
        if @result.success?
          respond response: :success
        else
          respond response: :failure, message: @result.messages[:error]
        end
    end
end

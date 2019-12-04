class AccountingExportsController < AccountingExportBase
  def index
    result = AccountingExports::RequestHandler.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end

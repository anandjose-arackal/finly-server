class AccountingExportsController < BaseControllers::AccountingExportBase
  def index
    @result = AccountingExports::RequestHandler.(current_user, params)
    if @result.records.present?
      respond
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
end

class AccountingExportsController < BaseControllers::WebBase
  def index
    @result = AccountingExports::RequestHandler.(current_user, params)
    respond
  end
end

class BaseControllers::AccountingExportBase < ApplicationController

  protect_from_forgery with: :null_session

  def authentication_scope
    :accounting_export
  end

  # def verify_user_session(doorkeeper_token)
  #   true
  # end

end

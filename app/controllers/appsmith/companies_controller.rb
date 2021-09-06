class Appsmith::CompaniesController < BaseControllers::AppsmithBase

  def create
    @op = Admin::Companies::Create.(current_user, params)
    if @op.success?
      respond response: :success
    else
      respond response: :failure, message: @op.messages[:error]
    end
  end

end


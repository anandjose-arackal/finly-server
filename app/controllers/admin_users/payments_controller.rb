class AdminUsers::PaymentsController < BaseControllers::AdminBase

  def status_check
    @result = Admin::Payments::StatusCheck.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def change_status
    @result = Admin::Payments::ChangeStatus.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end
  private

end

class AdminUsers::PaymentsController < BaseControllers::AdminBase

  def status_check
    @result = Admin::Payments::StatusCheck.(current_user, params)
    respond
  end

  def change_status
    @result = Admin::Payments::ChangeStatus.(current_user, params)
    respond
  end
end

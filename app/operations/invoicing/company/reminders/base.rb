class Invoicing::Company::Reminders::Base < Invoicing::Company::Base

  def reminder_params
    params.require(:reminder).permit(:days, :reference_date_type, :timeframe_type)
  end
end
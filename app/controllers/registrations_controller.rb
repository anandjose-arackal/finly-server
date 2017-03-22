class RegistrationsController < ApplicationController
  skip_before_filter :verify_authenticity_token, :only => [:download_resources]

  def preview
    @result = Company::Preview.(nil, params)
    if @result.success?
      respond response: :success, messages: @result.messages[:success]
    else
      respond response: :error, messages: @result.messages[:error]
    end
  end

  def resource_requests
    @result = ResourceRequests::Create.(nil, params)
    respond
  end

  def resources_download
    case params[:file_index]
      when '1'
        file_url = "#{Rails.root}/public/common/files/Say_No_to_Spreadsheets.pdf"
      when '2'
        file_url = "#{Rails.root}/public/common/files/Expense_Management_Checklist.pdf"
      else
        file_url = "#{Rails.root}/public/common/files/Say_No_to_Spreadsheets.pdf"
    end
    send_file file_url, :type=>"application/pdf"
  end

  private

  def resource_request_params
    params.require(:request).permit(:name, :email, :mobile_number)
  end


end

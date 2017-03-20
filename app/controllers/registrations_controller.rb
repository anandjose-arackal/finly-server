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

  def download_resources
    if params[:file_index].to_i == 1 
      file = '/common/files/Say_No_to_Spreadsheets.pdf'
    elsif params[:file_index].to_i == 2
      file = '/common/files/Expense_Management_Checklist.pdf'
    end

    resource_request = ResourceRequest.new(resource_request_params)
    if resource_request.save!
      @result = {success: true, file_src: file}
      respond_to do |format|
        format.json{ render json: @result.as_json}
      end
    end
  end

  private

  def resource_request_params
    params.require(:request).permit(:name, :email, :mobile_number)
  end


end

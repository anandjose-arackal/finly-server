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
    @result = ResourceRequests::Create.(nil, params)
    if @result.success?
      respond_to do |format|
        format.json {send_file @result.file_url, :type=>"application/pdf"}
      end
    else
      respond_to do |format|
        format.json {
          render js: "ohSnap('Something')"
        }
      end
    end
  end

  private

  def resource_request_params
    params.require(:request).permit(:name, :email, :mobile_number)
  end


end

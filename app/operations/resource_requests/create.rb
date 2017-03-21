class ResourceRequests::Create < BaseOperation

  attr_accessor :resource_params, :resource_request

  class ResourceRequests::Create::ResourceRequestPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

  def pre_validate
    if params.blank?
      add_message :error, "Invalid request"
    end
  end

  def init
    self.resource_params = resource_request_params
  end

  def pre_process
    case params[:file_index]
      when '1'
        resource_params[:resource_file_name] = 'Say_No_to_Spreadsheets'
      when '2'
        resource_params[:resource_file_name] = 'Expense_Management_Checklist'
      else
        # do nothing
    end
  end

  def process
    self.resource_request = ResourceRequest.new(resource_params)
    unless resource_request.save
      messages[:error] = resource_request.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Your download will begin shortly"

    Constants::RESOURCE_DOWNLOAD_EMAIL_ID.each do |recipient|
      DemoMailer.delay.notify_resource_download(resource_request, recipient)
    end
  end

  def success
    params[:file_url] = "#{Rails.root}/public/common/files/#{resource_request.resource_file_name}.pdf"
    ResourceRequests::Create::ResourceRequestPresenter.new(nil, params, messages)
  end

  private

  def resource_request_params
    params.require(:request).permit(:name, :email, :mobile_number)
  end
end
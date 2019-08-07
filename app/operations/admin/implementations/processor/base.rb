class Admin::Implementations::Processor::Base < BackgroundOperation
  include EventBus::Subscriber

  attr_accessor :master, :implementation_request, :company, :input

  def self.data_source(source = NoObject)
    @data_source = source unless source == NoObject
    @data_source
  end

  def self.headers(headers = NoObject)
    @headers = headers unless headers == NoObject
    @headers
  end

  def headers
    self.class.headers
  end

  def data_source
    self.class.data_source
  end

  def pre_validate
    if params.blank? or params[:implementation_request_id].blank? or params[:admin_user_id].blank?
      add_message :error, 'Error in request'
      return
    end
  end

  def init
    self.implementation_request = AdminImplementationRequest.find_by id: params[:implementation_request_id]
    self.user = AdminUser.find_by id: params[:admin_user_id]
    self.company = self.implementation_request&.company
  end

  def validate
    if self.implementation_request.blank? or self.company.blank?
      add_message :error, 'Error in request'
      return
    end
    valid_request
  end

  def valid_request

  end

  def pre_process
    progress_update :in_progress, completed_items: 0
  end

  def process

  end

  def post_process
    progress_update :completed
  end

  def progress_update(status, completed_items: nil, message: nil)
    self.implementation_request.status = status
    self.implementation_request.completed_items = completed_items if completed_items
    self.implementation_request.message = message if message
    self.implementation_request.save

    if [:error, :failed].include?(status)
      add_message :error, message || 'Unknown error occurred'
      return
    end
  end

  def export(headers, contents)
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = exporter.generate_xls_file
    self.implementation_request.result_file = file
    self.implementation_request.save
  end

  def file_name
    ['export', '.xlsx']
  end

end
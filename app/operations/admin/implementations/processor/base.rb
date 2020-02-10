class Admin::Implementations::Processor::Base < BackgroundOperation
  include EventBus::Subscriber
  include Dry::Monads[:result]

  attr_accessor :master, :implementation_request, :company, :input

  def self.headers(headers = {})
    @headers = headers unless headers == {}
    @headers
  end

  def headers
    self.class.headers
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
    progress_update :in_progress
  end

  def process

  end

  def post_process
    progress_update :completed
  end

  def item_complete(success)
    self.implementation_request.completed_items = 0 if self.implementation_request.completed_items.nil?
    self.implementation_request.success_items = 0 if self.implementation_request.success_items.nil?
    self.implementation_request.failed_items = 0 if self.implementation_request.failed_items.nil?
    self.implementation_request.completed_items += 1
    self.implementation_request.success_items += 1 if success
    self.implementation_request.failed_items += 1 unless success
    self.implementation_request.save
  end

  def progress_update(status, message: nil)
    self.implementation_request.status = status
    #self.implementation_request.completed_items = completed_items if completed_items
    self.implementation_request.message = message if message

    case status
    when :in_progress
    when :failed, :error
      add_message :error, message || 'Unknown error occurred'
      self.implementation_request.completed_at = DateTime.now
    when :completed
      self.implementation_request.completed_at = DateTime.now
    end

    self.implementation_request.save
  end

  def export(headers, contents)
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = exporter.generate_xls_file
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

  def file_name
    ['export', '.xlsx']
  end

end
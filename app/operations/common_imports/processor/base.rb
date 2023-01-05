class CommonImports::Processor::Base < BackgroundOperation
  include EventBus::Subscriber
  include Dry::Monads[:result]
  sidekiq_options queue: :low

  attr_accessor :master, :common_import_request, :company, :input

  def self.headers(headers = {})
    @headers = headers unless headers == {}
    @headers
  end

  def headers
    self.class.headers
  end

  def pre_validate
    if params.blank? or params[:common_import_request_id].blank? or params[:user_id].blank?
      add_message :error, 'Error in request'
      return
    end
  end

  def init
    self.common_import_request = CommonImportRequest.find_by id: params[:common_import_request_id]
    self.user = User.find_by id: params[:user_id]
    self.company = self.common_import_request&.company
  end

  def validate
    if self.common_import_request.blank? or self.company.blank?
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
    self.common_import_request.completed_items = 0 if self.common_import_request.completed_items.nil?
    self.common_import_request.success_items = 0 if self.common_import_request.success_items.nil?
    self.common_import_request.failed_items = 0 if self.common_import_request.failed_items.nil?
    self.common_import_request.completed_items += 1
    self.common_import_request.success_items += 1 if success
    self.common_import_request.failed_items += 1 unless success
    self.common_import_request.save
  end

  def progress_update(status, message: nil)
    self.common_import_request.status = status
    #self.common_import_request.completed_items = completed_items if completed_items
    self.common_import_request.message = message if message

    case status
    when :in_progress
    when :failed, :error
      add_message :error, message || 'Unknown error occurred'
      self.common_import_request.completed_at = DateTime.now
    when :completed
      self.common_import_request.completed_at = DateTime.now
    end

    self.common_import_request.save
  end

  def export(headers, contents)
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = exporter.generate_xls_file
    self.common_import_request.result_file = file
    self.common_import_request.save
    progress_update(:completed)
  end

  def file_name
    ['export', '.xlsx']
  end

end
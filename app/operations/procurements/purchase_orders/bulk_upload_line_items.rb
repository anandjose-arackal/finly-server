class Procurements::PurchaseOrders::BulkUploadLineItems < Procurements::PurchaseOrders::Base

  attr_accessor :file, :parsed_data, :response_presenter, :errors_found,
                :result_data, :item_details,
                :headers, :contents, :validate_operation

  def pre_validate
    Rails.logger.fatal "FROM BulkUploadLineItems pre_validate,\n #{params.inspect}"
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank? or params[:file].blank?
      add_message :error, 'Error loading file. File not uploaded correctly'
      return
    end
  end

  def init
    Rails.logger.fatal "FROM BulkUploadLineItems start of init,\n #{params.inspect}"
    self.file = params[:file]
    headers = [:description, :item_number, :department_id, :cost_center_id, :comment, :item_code, :hsn_sac, :quantity, :unit_of_measurement, :rate, :discount, :tax, :total]
    begin
      self.parsed_data = ImportUtil.load_spreadsheet(file, headers, {skip_empty_lines: true})
    rescue Ole::Storage::FormatError => e
      add_message :error, "File Format error. Please re-save your Excel sheet in 2007 format or greater."
    end

  end

  def validate
    if parsed_data.blank?
      add_message :error, 'Nothing to process'
      return
    end 

  end

  def process
    self.validate_operation = Procurements::PurchaseOrders::BulkValidateFileData.(user, {item_details: self.parsed_data})
    Rails.logger.fatal "FROM BulkUploadLineItems validate_operation,\n #{validate_operation.inspect}"
    if validate_operation.success?

    else
      self.contents = validate_operation.contents
      self.headers = validate_operation.headers
      add_message :error, "Some of the items have errors, please check the downloaded file to resolve them"
      return
    end
  end

  def success
    # params[:parsed_data] = self.parsed_data
    params[:parsed_data] = self.validate_operation.item_details
    Procurements::PurchaseOrders::BulkUploadLineItems::SuccessPresenter.new(user, params, messages)
  end

  # this method should create the temporary file that can be linked in the front end
  def failure
    exporter = Exporter::Spreadsheet.new(user, {headers: self.headers, contents: self.contents})
    file = Tempfile.new("bulk_item_import_errors.xls")
    open(file.path, 'wb') do |f|
      f.write exporter.generate_xls
    end
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 2.day)
    params[:result_file_path] = temp_file.file.url
    Procurements::PurchaseOrders::BulkUploadLineItems::FailurePresenter.new(user, params, messages)
  end

  class Procurements::PurchaseOrders::BulkUploadLineItems::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :parsed_data

    def init
      self.parsed_data = params[:parsed_data]
    end
  end

  class Procurements::PurchaseOrders::BulkUploadLineItems::FailurePresenter < BaseOperation::BasePresenter::FailurePresenter

    attr_accessor :result_file_path

    def init
      self.result_file_path = params[:result_file_path]
    end
  end

end
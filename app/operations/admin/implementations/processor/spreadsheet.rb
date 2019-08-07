class Admin::Implementations::Processor::Spreadsheet < Admin::Implementations::Processor::Base

  class Admin::Implementations::Processor::Spreadsheet::Result
    attr_accessor :message, :success

    def initialize(success, message=nil)
      self.success = success
      self.message = message
    end

  end

  def validate
    super()
    return if has_errors?

    if self.implementation_request.request_file.blank?
      add_message :error, 'File has not been uploaded'
      return
    end
  end

  def process
    sheets = Roo::Spreadsheet.open(self.implementation_request.request_file.url)
    self.input = sheets.default_sheet
    output = []
    self.input.each do |row|
      data = {}
      row.each_with_index do |value, index|
        data[headers[index]] = value
      end
      result = process_row(data)
      unless result.is_a?(Admin::Implementations::Processor::Spreadsheet::Result)
        raise "invalid result"
      end

      unless result.success?
        result << result.message
      end
      output << row
    end
  end

  def process_row(data)
    fail("Error while processing item")
  end

  def fail(message)
    message ||= "Error while processing item"
    Admin::Implementations::Processor::Spreadsheet::Result.new false, message
  end

end
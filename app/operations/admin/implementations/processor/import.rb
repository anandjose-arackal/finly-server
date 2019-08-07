class Admin::Implementations::Processor::Import < Admin::Implementations::Processor::Base

  class Admin::Implementations::Processor::Import::Result
    attr_accessor :message, :success

    def initialize(success, message = nil)
      self.success = success
      self.message = message

      if message and message.is_a?(Array)
        message = message.join(', ')
      end

      unless success and not message
        self.message = "Error while processing item"
      end
    end

    def success?
      !!self.success
    end

  end

  def self.halt_on_failure!
    @halt_on_failure = true
  end

  def self.halt_on_failure?
    !!@halt_on_failure
  end

  def halt_on_failure?
    self.class.halt_on_failure?
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
    sheets = Roo::Spreadsheet.open(self.implementation_request.request_file.path)
    self.input = sheets
    output = []
    failed = false
    self.input.each_with_index do |row, index|
      if index == 0
        output << row
        next
      end

      if failed and self.halt_on_failure?
        output << row
        next
      end

      data = {}
      row.each_with_index do |value, index|
        data[headers[index]] = value
      end

      result = process_row(data)
      unless result.is_a?(Admin::Implementations::Processor::Import::Result)
        raise "invalid result"
      end

      unless result.success?
        row << result.message
        failed = true
      end
      output << row
    end
    export headers, output
  end

  def process_row(data)
    result success: false, message: "Error while processing item"
  end

  def result(success, message = nil)
    Admin::Implementations::Processor::Import::Result.new success, message
  end

end
class Admin::Implementations::Processor::Import < Admin::Implementations::Processor::Base

  class Admin::Implementations::Processor::Import::Result
    attr_accessor :message, :success

    def initialize(success, message = nil)
      self.success = success
      self.message = message
      if message and message.is_a?(Array)
        message = message.join(', ')
      end
      # unless success and message.present?
      #   self.message = "Error while processing item"
      # end
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
    self.input = Roo::Spreadsheet.open(self.implementation_request.request_file.path)
    output = []
    failed = false
    self.input.each_with_index do |row, index|
      if index == 0
        next
      end

      if failed and self.halt_on_failure?
        row << "Ignored"
        output << row
        next
      end

      data = {}
      row.each_with_index do |value, index|
        data[headers[index]] = value
      end

      result = process_row(data)
      unless result.is_a?(Admin::Implementations::Processor::Import::Result)
        item_complete false
        raise "invalid result"
      end

      unless result.success?
        item_complete false
        row << result.message
        failed = true
      end
      if result.success?
        row << result.message
      end
      output << row
      item_complete true
    end
    export headers, output
  end

  def template
    Exporter::Spreadsheet.new(user, {headers: headers, contents: []})
  end

  def process_row(data)
    id = data[:id]
    destroy_action = data[:destroy]
    if destroy_action&.downcase == 'y'
      destroy_records(data)
    elsif id.present?
      update_record(data)
    else
      create_record(data)
    end
  end

  def destroy_records(data)
      result success: false, message: "Destroy action cant perform"
  end

  def update_record(data)
    result success: false, message: "Update action cant perform"
  end

  def create_record(data)
    result success: false, message: "Create action cant perform"
  end

  def result(success, message = nil)
    Admin::Implementations::Processor::Import::Result.new success, message
  end

end
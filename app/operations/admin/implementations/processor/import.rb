class Admin::Implementations::Processor::Import < Admin::Implementations::Processor::Base
  include Admin::Implementations::Processor::Finders

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
    if Rails.env.production?
      self.input = Roo::Spreadsheet.open(self.implementation_request.request_file&.url)
    else
      self.input = Roo::Spreadsheet.open(self.implementation_request.request_file&.path)
    end
    output = []
    failed = false
    self.implementation_request.update(requested_items: (input&.count-1))
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
        next if index >= headers.size
        data[headers.keys[index]] = value
      end
      #begin
        result = process_row(data)
        unless result.is_a?(Admin::Implementations::Processor::Import::Result)
          item_complete false
          #raise "invalid result"
        end
      # rescue Exception => e
      #   result false, "#{e.message}"
      # end

      unless result.success?
        item_complete false
        row << result.message
        failed = true
      end
      if result.success?
        row << result.message
        item_complete true
      end
      output << row
    end
    export headers.values, output
  end

  def template
    Exporter::Spreadsheet.new(user, {headers: headers, contents: []})
  end

  def process_row(data)
    id = data[:id]
    destroy_action = data[:destroy]
    invite_action = data[:invite]
    if destroy_action&.to_s&.downcase == 'y'
      response = destroy_records(data)
    elsif destroy_action&.to_s&.downcase == 'activate'
      response =destroy_records(data)
    elsif invite_action.to_s.downcase == 'y'
      response = invite(data)
    elsif id.present?
      response =update_record(data)
    else
      response =create_record(data)
    end
      response
  end

  def destroy_records(data)
    result success: false, message: "Cannot destroy"
  end

  def update_record(data)
    result success: false, message: "Update action cant perform"
  end

  def create_record(data)
    result success: false, message: "Create action cant perform"
  end

  def invite(data)
    result sucess: false, message: "Create action cant perform"
  end

  def result(success, message = nil)
    Admin::Implementations::Processor::Import::Result.new success, message
  end

end
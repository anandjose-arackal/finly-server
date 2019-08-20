class Admin::Implementations::Processor::ImportTemplate < Admin::Base
  include EventBus::Subscriber

  attr_accessor :master, :company, :input, :file_url

  def self.headers(headers = NoObject)
    @headers = headers unless headers == NoObject
    @headers
  end

  def headers
    self.class.headers
  end

  def pre_validate
    if params.blank?
      add_message :error, 'Error in request'
      return
    end
  end

  def init
    self.company = Company.find_by id: params[:company_id]
  end

  def validate
    if self.company.blank?
      add_message :error, 'Error in request'
      return
    end
  end

  def process
    self.file_url = export(self.headers, contents)
  end

  def contents
    contents = []
  end

  def export(headers, contents)
    exporter = Exporter::Spreadsheet.new(user, {headers: headers, contents: contents})
    file = exporter.generate_xls_file
    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    return temp_file.file.url
  end

  def file_name
    ['export', '.xlsx']
  end

  def success
    params[:file_url] = file_url
    Admin::Implementations::Processor::ImportTemplate::ImportPresenter .new(user, params, messages)
  end

  class Admin::Implementations::Processor::ImportTemplate::ImportPresenter  < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :file_url

    def init
      self.file_url = params[:file_url]
    end
  end

end
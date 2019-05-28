# action to export a money_request as xml
# params:
# report_ids: ids of the report to be exported

class Export::MoneyRequest::AsXml < Export::MoneyRequest::Base

  attr_accessor :money_requests, :result, :money_request_name, :default_column_names,
                :column_names, :data

  def personalizer
    {
        post_process: {
            before: Personalizer::Process.new([:export, :money_requests], :as_xml, self)
        }
    }
  end

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def init
    index_presenter = ::MoneyRequests::Index.(user, params)
    id = (params[:money_request_id] or params[:money_requests_id]).split(',') rescue nil
    self.money_requests = index_presenter&.money_requests.include_details
    if id.present?
      self.money_requests = self.money_requests&.with_id(id)
    end
    self.default_column_names = header
  end

  def authorize
    unless money_requests
      messages[:error] << "Reports to export not found."
    end
  end

  def process
    self.column_names = default_column_names
    self.data = []
    money_requests.each do |mr|
      self.data << retrieve_data(mr)
    end
  end

  def post_process
    #adding money_request names in the name of the file
    self.money_request_name = "money_request_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    Export::Base::ExportPresenter.new(user, {header: self.column_names, data: self.data, money_request_name: money_request_name}, messages)
  end

end

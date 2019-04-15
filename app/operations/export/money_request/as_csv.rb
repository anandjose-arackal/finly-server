# exporting a particular money_request as CSV
# params:
# money_request_ids: id of the money requests that is to be exported

class Export::MoneyRequest::AsCsv < Export::MoneyRequest::Base

  attr_accessor :money_request, :preferences, :result, :money_request_name, :default_column_names

  def authorized_user_types
    [:employee, :manager, :finance_manager, :admin, :auditor]
  end

  def init
    index_presenter = ::MoneyRequests::Index.(user, params)
    id = (params[:money_request_id] or params[:money_request_id]).split(',') rescue nil
    self.money_request = index_presenter&.money_requests.include_details
    if id.present?
      self.money_request = self.money_request&.with_id(id)
    end
    self.default_column_names = header
  end

  def authorize
    unless money_request
      messages[:error] << "Money Requests not found."
    end
  end

  def validate

  end

  def process
    self.result = CSV.generate do |csv|
      csv << default_column_names
      money_request.each do |mr|
          csv << retrieve_data(mr)
      end
    end
  end

  def post_process
    self.money_request_name = "money_request_#{Date.today.day}_#{Date.today.month}_#{Date.today.year}"
  end

  def success
    Export::Base::ExportPresenter.new(user, {data: result, money_request_name: self.money_request_name}, messages)
  end

end

class BankTransfer::Users::Exports::Base < BankTransfer::Users::Base
  attr_accessor  :headers, :users

  def init
    ids = params[:ids] || params[:user_ids]
    unless ids.is_a?(Array) or ids.blank?
      ids = ids.split(',')
    end
    result = BankTransfer::Users::Index.(user, params)
    unless result.success?
      add_message :error, result.messages[:error]
      return
    end
    self.users = result.users.includes(:profile)
    self.users = self.users.where(id: ids) if ids.present?
    self.headers = default_headers
  end

  class BankTransfer::Users::Exports::Base::ExportPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :data, :header, :file_name, :result_file_path

    def init
      self.data = params[:data]
      self.header = params[:header]
      self.file_name = params[:export_name]
      self.result_file_path = params[:result_file_path]
    end

  end

  private

  def default_headers
    [
        "Employee ID",
        "Name",
        "Email",
        "Mobile Number",
        "Status"
    ]
  end


  def retrieve_data(user)
    data_arr = []
    data_arr << user.profile&.employee_id.to_s
    data_arr << user.name
    data_arr << user.email
    data_arr << user.mobile_number
    data_arr << user.active
    data_arr
  end
end

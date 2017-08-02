class Admin::FundsLoadRequests::Approve < Admin::Base
  attr_accessor :funds_load_request

  def init
    self.funds_load_request = CompanyFundsLoadRequest.find(params[:id])
    unless funds_load_request.present?
      add_message :error, "Company Funds Load Request Not Found"
    end
  end

  def process
    # Add Company Balance for the particular company

    if true # todo replace with logic for updaation of company balance
      self.funds_load_request.update(is_active: false)
      add_message :success, "Successfully added balance for Company"
    end
  end
end
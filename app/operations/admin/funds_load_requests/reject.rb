class Admin::FundsLoadRequests::Reject < Admin::Base

  attr_accessor :funds_load_request

  def init
    self.funds_load_request = CompanyFundsLoadRequest.find(params[:id])
    unless funds_load_request.present?
      add_message :error, "Company Funds Load Request Not Found"
      return
    end
  end

  def process
    # just mark the request as not active, nothing else to do
    unless funds_load_request.update(is_active: false)
      add_message :error, funds_load_request.errors.full_messages
    end
  end
end
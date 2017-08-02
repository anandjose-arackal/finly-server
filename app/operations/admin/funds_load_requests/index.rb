class Admin::FundsLoadRequests::Index < Admin::Base
  attr_accessor :bank_type_id, :funds_load_requests

  def init
    self.bank_type_id = params[:bank_type_id]
  end

  def process
    self.funds_load_requests = CompanyFundsLoadRequest.with_bank_type_id(bank_type_id).with_active
  end

  def success
    params[:funds_load_requests] = self.funds_load_requests
    Admin::FundsLoadRequests::Index::IndexPresenter.new(user, params)
  end

  class Admin::FundsLoadRequests::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :funds_load_requests

    def init
      self.funds_load_requests = params[:funds_load_requests]
    end
  end
end
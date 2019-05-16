class PaymentAgreement::Count < PaymentAgreement::Base

  attr_accessor :statuses

  def init
    self.statuses ||= {}
  end

  def validate
  end

  def process
    result  = ::PaymentAgreement::Index.(user, params)
    if result.success?
      self.statuses = result.purchase_requests.joins(:status).group('purchase_request_statuses.name').count
    end
  end

  def success
    params[:statuses] = self.statuses
    PaymentAgreement::Count::CountPresenter.new(user, params, messages)    
  end

  class PaymentAgreement::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :statuses

    def init
      self.statuses = params[:statuses]
    end

  end

end
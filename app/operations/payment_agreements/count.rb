class PaymentAgreements::Count < PaymentAgreements::Base

  attr_accessor :statuses

  def init
    self.statuses ||= {}
  end

  def validate
  end

  def process
    result  = ::PaymentAgreements::Index.(user, params)
    if result.success?
      self.statuses = result.payment_agreements.joins(:status).group('payment_agreement_statuses.name').count
    end
  end

  def success
    params[:statuses] = self.statuses
    PaymentAgreements::Count::CountPresenter.new(user, params, messages)    
  end

  class PaymentAgreements::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :statuses

    def init
      self.statuses = params[:statuses]
    end

  end

end
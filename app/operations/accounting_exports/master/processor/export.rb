class AccountingExports::Master::Processor::Export < BaseOperation
  include EventBus::Subscriber

  attr_accessor :records

  class AccountingExports::Master::Processor::Export::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :records

    def init
      self.records = params[:records]
    end

  end

  def success
    params[:records] = self.records
    AccountingExports::Master::Processor::Export::SuccessPresenter.new(user, params, messages)
  end

end
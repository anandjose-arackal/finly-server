class AccountingExports::Master::Processor::Export < BaseOperation
  include EventBus::Subscriber

  attr_accessor :records

  class AccountingExports::Master::Processor::Export::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :records

    def init
      self.records = params[:records]
    end

  end

  def process
   objects = get_records(params)
   self.records = set_record_format(objects)
  end

  def success
    AccountingExports::Master::Processor::Export::SuccessPresenter.new(user, params, messages)
  end

  def set_record_format(objects)
    []
  end
end
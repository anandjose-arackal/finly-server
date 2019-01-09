class Invoicing::Transactions::Count < Invoicing::Transactions::Base

  attr_accessor :count, :transactions


  class Invoicing::Transactions::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end

  def process
    result = Invoicing::Transactions::Index.(user, params)
    if result.success?
      self.count = result.incoming_payments.count
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Invoicing::Transactions::Count::CountPresenter.new(user, params, messages)
  end

end
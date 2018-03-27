class Invoicing::Customer::Count < Invoicing::Customer::Base

  attr_accessor :count

  class Invoicing::Customer::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end

  end


  def process
    result = Invoicing::Customer::Index.(user, params)
    if result.success?
      self.count = result.customers.count
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Invoicing::Customer::Count::CountPresenter.new(user, params, messages)
  end
end
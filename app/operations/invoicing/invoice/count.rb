class Invoicing::Invoice::Count < Invoicing::Invoice::Base

  attr_accessor :count

  class Invoicing::Invoice::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end

  def process
    result = Invoicing::Invoice::Index.(user, params)
    if result.success?
      self.count = result.invoices.count
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Invoicing::Invoice::Count::CountPresenter.new(user, params, messages)
  end
end


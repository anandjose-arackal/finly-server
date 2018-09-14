class Procurements::Count < Procurements::Base

  attr_accessor :count

  class Procurements::Count::CountPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :count

    def init
      self.count = params[:count]
    end
  end

  def process
    result = Procurements::Index.(user, params)
    if result.success?
      self.count = result.procurements.count
    else
      add_message :error, result.messages[:error]
    end
  end

  def success
    params[:count] = self.count
    Procurements::Count::CountPresenter.new(user, params, messages)
  end
end


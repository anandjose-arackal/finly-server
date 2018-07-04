class Procurements::Index < Procurements::Base
  attr_accessor :procurements

  def init
    self.procurements = user.company.procurements
  end

  def process
  end

  def success
    params[:procurements] = self.procurements
    Procurements::Index::IndexPresenter.new(user, params, messages)
  end

  class Procurements::Index::IndexPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :procurements

    def init
      self.procurements = params[:procurements]
    end
  end
end
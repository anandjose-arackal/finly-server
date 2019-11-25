class Autocomplete::BbpsBillers < BaseOperation

  attr_accessor :bbps_billers

  def init
    params[:filter_search] = params[:filter_search].strip if params[:filter_search].present?
  end

  def process
    op = Docs::UtilityBills::Billers::Ops::Index.(params: params, current_user: user)
    if op.success?
      self.bbps_billers = op['result']['bbps_billers']
    end
  end

  def success
    params[:bbps_billers] = self.bbps_billers
    Autocomplete::BbpsBillers::BbpsBillerPresenter.new(user, params, messages)
  end

  class Autocomplete::BbpsBillers::BbpsBillerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :bbps_billers

    def init
      self.bbps_billers = params[:bbps_billers]
    end

  end
end
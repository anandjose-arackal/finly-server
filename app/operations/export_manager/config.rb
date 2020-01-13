class ExportManager::Config < BaseOperation
  attr_accessor :exports

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.exports = ExportManager::Master.fetch(user, params)
  end

  def success
    ExportManager::Config::SuccessPresenter.new(user, {exports: self.exports}, messages)
  end


  class ExportManager::Config::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :exports

    def init
      self.exports = params[:exports]
    end

  end
end
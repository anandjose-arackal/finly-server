class ExportManager::Config < BaseOperation
  attr_accessor :exports

  def pre_validate
    user_present? and params_present?
  end

  def init
    self.exports = []
    subscribers = ExportManager::Master::BaseMaster.subscribers
    subscribers.each do |_, list|
      list.each do |master|
        self.exports << master.config if params[:screen].blank? or master.screen.to_s == params[:screen].to_s
      end
    end
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
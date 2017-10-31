class Settlement::SReport::Completed::Index < Settlement::SReport::Completed::Base
  attr_accessor :reports

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    reports_presenter = Report::Index.(user, params)
    unless reports_presenter.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    self.reports = reports_presenter.reports.completed
  end

  def success
    params[:reports] = self.reports
    Settlement::SReport::Pending::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Pending::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports

    def init
      self.reports = params[:reports]
    end
  end


end
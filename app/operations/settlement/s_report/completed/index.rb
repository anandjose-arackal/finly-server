class Settlement::SReport::Completed::Index < Settlement::SReport::Completed::Base
  attr_accessor :reports

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    reports_presenter = Reports::Index.(user, params)
    unless reports_presenter.success?
      add_message :error, reports_presenter.messages[:error]
      return
    end
    self.reports = reports_presenter.reports.completed.sort_by_updated_at
  end

  def success
    params[:reports] = self.reports
    Settlement::SReport::Pending::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Pending::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :paginated_reports

    def init
      self.reports = params[:reports]
      per_page = params[:per_page] || 30
      self.paginated_reports = self.reports.paginate(page: params[:page], per_page: per_page)
    end
  end


end
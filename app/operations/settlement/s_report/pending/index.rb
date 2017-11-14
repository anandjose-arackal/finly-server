class Settlement::SReport::Pending::Index < Settlement::SReport::Pending::Base
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
    self.reports = reports_presenter.reports.approved
  end

  def success
    params[:reports] = self.reports
    Settlement::SReport::Pending::Index::SuccessPresenter.new(user, params, messages)
  end

  class Settlement::SReport::Pending::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :reports, :paginated_reports

    def init
      self.reports = params[:reports]
      page_size = params[:page_size] || 30
      self.paginated_reports = self.reports.paginate(page: params[:page], per_page: page_size)
    end
  end


end
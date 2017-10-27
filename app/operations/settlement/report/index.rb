class Settlement::Report::Index < Settlement::Report::Base
  attr_accessor :reports

  def authorized_user_types
    [:admin, :manager, :finance_manager, :auditor]
  end

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

end
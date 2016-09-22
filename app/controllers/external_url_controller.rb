class ExternalUrlController < ApplicationController

  before_action :authenticate_user!

  def report
    id = params[:id]
    report = current_user.reports.with_id(id).first rescue nil
    if report.blank? and current_user.manager?
      params[:view] = 'manager'
      result = Report::Show.(current_user, params)
      if result.success?
        report = result.report
      end
    end
    if report.blank? and current_user.finance_manager?
      params[:view] = 'finance_manager'
      result = Report::Show.(current_user, params)
      if result.success?
        report = result.report
      end
    end
    if report.blank? and current_user.admin?
      params[:view] = 'admin'
      result = Report::Show.(current_user, params)
      if result.success?
        report = result.report
      end
    end
    if report.present?
      redirect_to "#{root_url}#reports/params={\"view\":\"#{params[:view]}\"}"
    else
      redirect_to root_path
    end
  end

  def payment
    user = nil
    if current_user.manager?
      params[:view] = 'manager'
      result = User::Show.(current_user, params)
      if result.success?
        user = result.user
      end
    end
    if user.blank? and current_user.finance_manager?
      params[:view] = 'finance_manager'
      result = User::Show.(current_user, params)
      if result.success?
        user = result.user
      end
    end
    if user.blank? and current_user.admin?
      params[:view] = 'admin'
      result = User::Show.(current_user, params)
      if result.success?
        user = result.user
      end
    end
    if user.present?
      redirect_to "#{root_url}#settlements/params={\"view\":\"#{params[:view]}\"}"
    else
      redirect_to root_path
    end
  end

end

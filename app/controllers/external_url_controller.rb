class ExternalUrlController < ApplicationController



  def report
    id = params[:id]
    report = current_user.reports.with_id(id).first rescue nil
    params[:view] = 'personal'
    # todo use report controlling user to figure out user role for report
    if report.blank? && current_user.manager?
        params[:view] = 'manager'
        result = Reports::Show.(current_user, params) rescue nil
        if result&.success?
          report = result.report
        end
    end
    if report.blank? and current_user.finance_manager?
      params[:view] = 'finance_manager'
      result = Reports::Show.(current_user, params) rescue nil
      if result&.success?
        report = result.report
      end
    end
    if report.blank? and current_user.admin?
      params[:view] = 'admin'
      result = Reports::Show.(current_user, params)
      if result.success?
        report = result.report
      end
    end
    if report.present?
      redirect_to "#{root_url}#reports/#{report.id}/params={\"view\":\"#{params[:view]}\",\"preview\":true}"
      # redirect_to "#{root_url}#reports/params={\"view\":\"#{params[:view]}, report_id:#{report.id}\"}"
    else
      redirect_to root_path
    end
  end

  def money_request
    id = params[:id]
    money_request = current_user.money_requests.with_id(id).first rescue nil
    params[:view] = 'personal'
    # todo use money_request controlling user to figure out user role for money_request
    if money_request.blank? and current_user.manager?
      params[:view] = 'manager'
      result = MoneyRequest::Show.(current_user, params) rescue nil
      if result&.success?
        money_request = result.money_request
      end
    end
    if money_request.blank? and current_user.finance_manager?
      params[:view] = 'finance_manager'
      result = MoneyRequest::Show.(current_user, params) rescue nil
      if result&.success?
        money_request = result.money_request
      end
    end
    if money_request.blank? and current_user.admin?
      params[:view] = 'admin'
      result = MoneyRequest::Show.(current_user, params)
      if result.success?
        money_request = result.money_request
      end
    end
    if money_request.present?
      redirect_to "#{root_url}#requests/#{money_request.id}/params={\"view\":\"#{params[:view]}\",\"preview\":true}"
    else
      redirect_to root_path
    end
  end

  def payment
    user = nil
    id = params[:id]
    redirect_to root_path if id.blank?
    if current_user.id == id.to_i
      redirect_to "#{root_url}#settlements/#{id}"
      return
    end
    params[:view] = 'personal'
    if user.blank? and current_user.manager?
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
    end
  end

  def transaction
    id = params[:id]
    if id.blank?
      redirect_to root_path
      return
    end
    expense = current_user.expenses.with_id(id).first rescue nil
    if expense.blank?
      redirect_to root_path
      return
    end
    redirect_to "#{root_url}#expenses/params={\"preview\":true, \"id\":#{expense.id}}"
  end

end

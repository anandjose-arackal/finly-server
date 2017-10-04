class SummaryMailer::Index < BaseOperation
  attr_accessor :admin_summary_mail_configs, :manager_summary_mail_configs, :manager_report_summary_mail_configs, :manager_money_request_summary_mail_configs


  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    if user.company_admin?
      self.admin_summary_mail_configs = user.admin_summary_mail_configs
    end
    if user.manager? or user.finance_manager?
      self.manager_summary_mail_configs = user.manager_summary_mail_configs
      self.manager_report_summary_mail_configs = manager_summary_mail_configs.reports
      self.manager_money_request_summary_mail_configs = manager_summary_mail_configs.money_requests
    end
  end

  def success
    params[:admin_summary_mail_configs] = self.admin_summary_mail_configs
    params[:manager_summary_mail_configs] = self.manager_summary_mail_configs
    params[:manager_report_summary_mail_configs] = self.manager_report_summary_mail_configs
    params[:manager_money_request_summary_mail_configs] = self.manager_money_request_summary_mail_configs
    SummaryMailer::Index::SuccessPresenter.new(user, params, messages)
  end

  class SummaryMailer::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :admin_summary_mail_configs,
                  :manager_summary_mail_configs,
                  :manager_report_summary_mail_configs,
                  :manager_money_request_summary_mail_configs

    def init
      self.admin_summary_mail_configs = params[:admin_summary_mail_configs]
      self.manager_summary_mail_configs = params[:manager_summary_mail_configs]
      self.manager_report_summary_mail_configs = params[:manager_report_summary_mail_configs]
      self.manager_money_request_summary_mail_configs = params[:manager_money_request_summary_mail_configs]
    end

  end

end
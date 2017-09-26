class SummaryMailer::CompanyAdmin::Index < SummaryMailer::CompanyAdmin::Base
  attr_accessor :admin_summary_mail_configs

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
  end

  def init
    self.admin_summary_mail_configs = user.admin_summary_mail_configs
  end

  def success
    params[:admin_summary_mail_configs] = self.admin_summary_mail_configs
    SummaryMailer::CompanyAdmin::Index::SuccessPresenter.new(user, params, messages)
  end

  class SummaryMailer::CompanyAdmin::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :admin_summary_mail_configs

    def init
      self.admin_summary_mail_configs = params[:admin_summary_mail_configs]
    end

  end

end
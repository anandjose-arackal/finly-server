class SummaryMailer::Index < SummaryMailer::CompanyAdmin::Base
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
    if user.company_admin?
      self.admin_summary_mail_configs = user.admin_summary_mail_configs
    end
  end

  def success
    params[:admin_summary_mail_configs] = self.admin_summary_mail_configs
    SummaryMailer::Index::SuccessPresenter.new(user, params, messages)
  end

  class SummaryMailer::Index::SuccessPresenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :admin_summary_mail_configs

    def init
      self.admin_summary_mail_configs = params[:admin_summary_mail_configs]
    end

  end

end
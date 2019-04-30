class ApiApplicationController < BaseControllers::ApiBase

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) if Rails.env.production? }

  before_action :validate_user_admin
  before_action :append_params

  before_action :set_current_app

  protected
  def validate_user_admin
    head(401) unless current_user&.company_admin?
  end

  def append_params
    params[:view] = 'admin'
  end

  def set_current_app
    if current_app.to_sym == :em && current_device.to_sym == :api
      # check if the particular user has access to either one of the applications
      if current_user.expense_management_enabled? && current_user.disburse_enabled?
        # absolutely no change
      elsif current_user.expense_management_enabled?
        RequestStoreUtil.set_current_app(:em)
      elsif current_user.disburse_enabled?
        RequestStoreUtil.set_current_app(:ft)
      end
    end
  end

end

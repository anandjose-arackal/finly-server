class ApiApplicationController < ApplicationController

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) if Rails.env.production? }

  before_action -> { finly_authorize! :api }
  before_action :validate_user_admin
  before_action :append_params

  protected
  def validate_user_admin
    unless current_user&.company_admin?
      head(401)
    end
  end

  def append_params
    params[:view] = 'admin'
  end

end
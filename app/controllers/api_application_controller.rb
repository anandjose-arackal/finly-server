class ApiApplicationController < ApplicationController

  before_action { block_foreign_hosts(WhitelistedIpType.id_for(:api)) }
  before_action :authenticate_user!
  allow_oauth!
  before_action :validate_user_admin

  protected
  def validate_user_admin
    unless current_user&.company_admin?
      head(401)
    end
    params[:view] = 'admin'
  end

end
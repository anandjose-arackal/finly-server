class SettlementsController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = UserTeamService.new(current_user).team(UserRole.finance_manager_id, indirect_associations: true)
    @users = @users.with_balance_sheet if @users.present?
  end

  def show

  end

end

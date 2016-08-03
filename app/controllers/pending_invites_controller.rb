class PendingInvitesController < ApplicationController

  before_action :authenticate_user!
  before_action :load_service_objects

  def invite

  end

  def accept

  end

  def update

  end

  def destroy

  end

  private

  def load_service_objects
    @user_invite_service = UserInviteService.new(current_user)
  end

end

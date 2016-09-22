class PendingInvitesController < ApplicationController

  before_action :authenticate_user!, except: [:edit, :accept]


  def edit
    @pending_user = User.find_by_invitation_token(params[:invitation_token], true)
  end


  def create
    @result = User::Invite::Create.(current_user, params)
    if @result.present? and @result.success?
      respond(response: :success)
    else
      respond
    end
  end

  def update
    if params[:type].present?
      case params[:type].to_sym
        when :accept
          @result = User::Invite::Accept.(params)
        when :resend
          @result = User::Invite::Resend.(current_user, params)
        when :update
          @result = User::Invite::Update.(current_user, params)
      end
    end
    if @result.present? and @result.success?
      respond(response: :success)
    else
      respond
    end
  end

  def destroy
    @result = User::Invite::Destroy.(current_user, params)
    if @result.present? and @result.success?
      respond(response: :success)
    else
      respond
    end
  end

  def accept
    @result = User::Invite::Accept.(params)
    if @result.present? and @result.success?
      # sign_in @result.accepted_user, :bypass => true
      bypass_sign_in(@result.accepted_user)
      redirect_to root_url
      # respond
      # respond_to do |format|
      #   format.js {}
      # end
    else
      respond
      # respond_to do |format|
      #   format.js {}
      # end
    end
  end

  private
  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end

end

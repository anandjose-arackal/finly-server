class PendingInvitesController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :accept]

  def edit
    @pending_user = User.find_by_invitation_token(params[:invitation_token], true)
    @states = State::VALUES
    # i.e. if user has already signed in, redirect to login page
    unless @pending_user and @pending_user.invitation_token
      redirect_to new_user_session_path
    end
  end

  def create
    # # jugaad to test invite flow
    # params[:mobile_number] = params[:email]
    # params.delete(:email)
    # #### jugaad end

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
    # ap params
    # fail
    @result = User::Invite::Accept.(params)
    if @result.present? and @result.success?
      sign_in @result.accepted_user, :bypass => true
      # bypass_sign_in(@result.accepted_user)
      # redirect_to root_url
      # respond
      respond_to do |format|
        format.js { render js: "window.location = '#{root_url}';"}
        # format.js { render js: "window.location = '#{root_url}';"}
      end
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def activate_employee
    @states = State::VALUES
    @pending_user = User.find(params[:user_id])

    verified = true if #condition  #Should return boolean

    respond_to do |format|
      if verified
        format.html {render partial: 'activate_employee'}
      else
        format.html {render partial: 'verify_mobile'}
      end
    end
  end

  private
  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end

end

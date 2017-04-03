class PendingInvitesController < ApplicationController
  before_action :authenticate_user!, except: [:edit, :accept]
  allow_oauth!

  def edit
    @pending_user = User.find_by_invitation_token(params[:invitation_token], true)
    @states = State.all
    if @pending_user
      render partial: 'edit_invite'
    else
      render partial: 'edit_invite_not_found'
    end
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
    # ap params
    # fail
    @result = User::Invite::Accept.(params)
    if @result.present? and @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end


  def initiate_activation
    @pending_user = User.find(params[:user_id])
    respond_to do |format|
      format.html {render partial: 'verify_mobile'}
    end
  end


  def send_otp
    # setting the otp request type as 'user activation'
    params[:type] = OtpRequestType.id_for(:user_activation)
    @result = User::ManagerActivate::SendOtp.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  def activate_employee
    @states = State.all
    @pending_user = User.find(params[:user_id])

    if @pending_user.otp_verified?
      respond_to do |format|
        format.html {render partial: 'activate_employee'}
      end
    else
      # calling the initiate activation method
      initiate_activation
    end
  end

  # params["user"] = {"invitation_token"=>"", "email"=>"", "mobile_number"=>"8105739684", "first_name"=>"Sreeram", "maiden_name"=>"", "last_name"=>"Ramasubramanian", "profile_attributes"=>{"date_of_birth"=>"2006-03-01", "gender"=>"m", "address_1"=>"zsdzsdf", "address_2"=>"sdvsdvsa", "city"=>"sdvasdvsad", "state_id"=>"S18", "pin_code"=>"560003"}}, "type"=>"accept", "user_id"=>"10", "id"=>"sign_up"}

  def manager_sign_up
    @result = User::ManagerActivate::ManagerSignUp.(current_user, params)
    if @result.success?
      respond response: :success
    else
      respond response: :failure
    end
  end

  private
  def updated_user_invite_params
    params.require(:pending_invite).permit(:email, :company_id, :finance_manager, :manager, :manager_id, :finance_manager_id, :approves_to_id, :approves_finance_to_id, :team_mapping_id)
  end

end

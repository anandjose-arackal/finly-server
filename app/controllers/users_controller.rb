class UsersController < ApplicationController

  before_action :authenticate_user!

  # action to retrieve a particular user's details in the users screen - for everyone with a team - manager, finance manager etc.
  def show
    @result = User::Show.(current_user, params)
    ap @result.user
    respond_to do |format|
      format.json {render json: @result.user.as_json}
    end
  end

  # this would call the respective private method to update the respective attributes
  def update
    update_handler(params[:type])
  end

  # for list of team members - currently sending instance variables based on what was shown in the previous user listing
  def index
    @result = User::Index.(current_user, params)

    respond_to do |format|
      format.json {render json: @result.team.as_json}
    end
  end

  private
  def update_handler(type = nil)
    unless type
      flash.now[:error] = "Invalid data."
      # display error
      return
    end
    operation = nil
    success_message = nil
    case type
      when :password
        operation = User::Configuration::UpdatePassword.new(user, params)
        success_message = 'Password updated'
      when :team
        operation = User::Team::UpdateConfiguration.new(current_user, params)
        success_message = 'User team updated.'
      when :role
        operation = User::Role::Set.new(current_user, params)
        success_message = "Role updated"
      else
        # do nothing, ha!
    end
    unless operation.present?
      errors << 'Unknown error'
      return
    end
    @result = operation.run
    if operation.is_success?
      flash.now[:success] = success_message if success_message.present?
    else
      flash.now[:errors] - operation.errors
    end
  end

end

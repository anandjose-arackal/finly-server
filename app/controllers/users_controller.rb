class UsersController < ApplicationController

  before_action :authenticate_user!

  # action to retrieve a particular user's details in the users screen - for everyone with a team - manager, finance manager etc.
  def show
    @result = User::Show.(current_user, params)
    @managers = User::Team::GetManagers.new(current_user, params).run
    respond
  end

  # this would call the respective private method to update the respective attributes
  def update
    ap params
    
    update_handler(params[:type])
  end

  # for list of team members - currently sending instance variables based on what was shown in the previous user listing
  def index
    @result = User::Index.(current_user, params)

    respond_to do |format|
      format.json {render json: @result.team.as_json}
    end
  end

  # For destroying user manager mapping
  # params= { id: 22, mapping_id: 43 }
  def destroy
    @result = User::Team::Mappings::Destroy.(current_user, params)
    respond(response: :success)
  end

  def get_managers
    # params[:id] = current_user.id
    @result = User::Team::GetManagers.new(current_user, params).run
    respond
  end

  # placeholder action for importing file
  def mass_import

  end

  # action that imports from a CSV or Excel file for mass invitations
  def import
    import_op = User::Invite::Import.new(current_user, params)
    @result = import_op.run
    respond_to do |format|
      format.csv {send_data @result}
    end
  end

  private
  def update_handler(type = nil)
    unless type
      respond(response: :failure, message: 'Error while updating data')
      return
    end
    operation = nil
    success_message = nil
    case type
      when 'password'
        operation = User::Configuration::UpdatePassword.new(current_user, params)
        success_message = 'Password updated'
      when 'team'
        operation = User::Team::Mappings::Set.new(current_user, params)
        success_message = 'User team updated.'
      when 'role'
        operation = User::Role::Set.new(current_user, params)
        success_message = 'Role updated'
      when 'details'
        operation = User::Configuration::UpdateDetails.new(current_user, params)
        success_message = 'Details updated'
      when 'state'
        operation = User::Configuration::UpdateState.new(current_user, params)
        success_message = 'State updated'
      else
        # do nothing, ha!
    end
    unless operation.present?
      respond(response: :failure, message: 'Error while updating data')
      return
    end
    @result = operation.run
    respond(response: :success, message: success_message)
  end
end

class UserInviteService < BaseService
  attr_accessor :user

  def initialize(user)
    super()
    self.user = user
  end

  # Used for inviting users
  # Also, used for to resend invites. Recommended way by the Gem: https://github.com/scambra/devise_invitable
  def invite(params={})
    errors.clear
    if params.blank?
      errors 'Fill in the required details for inviting the user'
      return false
    end
    # params = invite_params params
    unless validate_invite params
      return false
    end

    # todo remove skip invite after testing
    u = User.invite!(params, self.user) do |u|
      u.skip_invitation = true
    end
    if u
      return true
    end
    self.errors << 'Error inviting user'
    false
  end

  def resend_invite(email)
    errors.clear
    unless User.find_by_email(email).present?
      errors << 'Invite not found'
      return false
    end
    u = User.invite!(email: email)do |u|
      u.skip_invitation = true
    end
    if u
      return true
    end
    self.errors = errors + u.errors.full_messages
    false
  end

  def accept_invitation(params={})
    errors.clear
    # params = invitation_accept_params params
    unless validate_accept_invite params
      return false
    end
    u = User.accept_invitation!(params)
    if u.present? and u.id.present?
      return true
    end
    self.errors += u.errors.full_messages
    false
  end

  def destroy_invite(user)
    errors.clear
    # invite can only be destroyed by inviting user or admin
    user = user
    if user.present? and user.is_a?(Integer)
      # Check only users who are yet to accept invitation
      user = User.invitation_not_accepted.find_by_id(user)
    end
    unless user.present?
      errors << 'Invite not found'
      return false
    end
    # todo validate if destroying user is inviting user or admin and if the user has not yet accepted the invite
    unless self.user.admin? or self.user == user.invited_by
      errors << 'Only inviting users can delete invites'
      return false
    end

    if user.destroy
      return true
    end
    self.errors += user.errors.full_messages
    false
  end

  private
  # def invite_params(params)
  #   params.permit(:email, :company, :company_id, :role_mapping_attributes, :team_mapping_attributes)
  # end
  #
  # def invitation_accept_params(params)
  #   params.permit(:invitation_token, :name, :mobile_number, :password)
  # end

  def validate_invite(params)
    unless user.admin? or user.manager? or user.finance_manager?
      errors << 'User does not have the permission to invite other users'
      return false
    end
    if params[:company].blank? and params[:company_id].blank?
      errors << 'A user can only be invited to a company. Please enter the company the user has to be assigned to'
      return false
    end
    company_id = params[:company_id] or params[:company]
    if company_id != self.user.company_id
      errors << 'User can only be invited in the same company'
      return false
    end

    if params[:email].blank?
      errors << 'User email is required for inviting users'
      return false
    end

    if User.find_by_email(params[:email]).present?
      errors << 'Cannot invite an existing user'
      return false
    end

    # Check if user is assigned a role and if the user can be assigned to that role
    unless validate_role_mapping params
      return false
    end

    # Only admins can invite users without managers/finance manager
    # Managers can only invite users into their team
    unless validate_team_mapping params
      return false
    end
    true
  end

  def validate_role_mapping(params)
    role_mapping = params[:role_mapping_attributes]
    if role_mapping.blank?
      errors << 'User must be assigned a role to be invited'
      return false
    end
    unless role_mapping.is_a?(Array) and role_mapping.size > 0
      errors << 'User must be assigned a role to be invited'
      return false
    end
    if self.user.manager?
      role_mapping.each do |role|
        rid = role[:user_role_id]
        unless rid.present? and (rid == UserRole.manager_id or rid == UserRole.employee_id)
          errors << 'User can only invite the user as an employee or manager'
          return false
        end
      end
    elsif self.user.finance_manager?
      role_mapping.each do |role|
        rid = role[:user_role_id]
        unless rid.present? and (rid == UserRole.finance_manager_id or rid == UserRole.employee_id)
          errors << 'User can only invite the user as an employee or finance manager'
          return false
        end
      end
    end
    true
  end

  def validate_team_mapping(params)
    team_mapping = params[:team_mapping_attributes]
    if self.user.manager? or self.user.finance_manager?
      if team_mapping.blank?
        errors << 'User must be assigned a manager and a finance manager to be invited'
        return false
      end
      unless team_mapping.is_a?(Array) and team_mapping.size > 0
        errors << 'User must be assigned a manager and a finance manager to be invited'
        return false
      end
      default_present = false
      valid = false
      if self.user.manager?
        team_mapping.each do |mapping|
          if mapping[:default]
            default_present = true
          end
          if mapping[:manager_id] == self.user.id
            valid = true
            break
          end
        end
      elsif self.user.finance_manager?
        team_mapping.each do |mapping|
          if mapping[:default]
            default_present = true
          end
          if mapping[:finance_manager_id] == self.user.id
            valid = true
            break
          end
        end
      end
      unless default_present and valid
        errors << 'User can only be assigned to the inviting user'
        return false
      end
    end
    true
  end

  def validate_accept_invite(params)
    if params.blank?
      errors << 'All fields are empty'
      return false
    end
    invitation_token = params[:invitation_token]
    name = params[:name]
    mobile_number = params[:mobile_number]
    password = params[:password]
    if invitation_token.blank?
      errors << 'Invite not found'
      return false
    end
    if name.blank?
      errors << 'Name can\'t be blank'
      return false
    end
    if mobile_number.blank?
      errors << 'Mobile number can\'t be blank'
      return false
    end
    if password.blank?
      errors << 'Password can\'t be blank'
      return false
    end
    true
  end

end
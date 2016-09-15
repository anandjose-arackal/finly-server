# action to invite a new user to the company
# params:
# invite:
#       company_id:
#       role_mapping_attributes:
#       team_mapping_attributes:
#


class User::Invite::Create < User::Invite::Base

  attr_accessor :new_user

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << "No user or param passed."
    end
  end

  def init
    self.invite_params = create_invite_params
  end

  def validate
    if invite_params[:company].blank? and invite_params[:company_id].blank? and invite_params['company_id'].blank?
      messages[:error] << 'A user can only be invited to a company. Please enter the company the user has to be assigned to'
      return false
    end
    company_id = invite_params[:company_id] or invite_params[:company] or invite_params['company_id']
    if company_id.to_i != self.user.company_id
      messages[:error] << 'User can only be invited in the same company'
      return false
    end

    if invite_params[:email].blank?
      messages[:error] << 'User email is required for inviting users'
      return false
    end

    if User.find_by_email(invite_params[:email]).present?
      messages[:error] << 'Cannot invite an existing user'
      return false
    end

    # checking validity of user role params
    role_mapping = invite_params[:role_mapping_attributes]
    if role_mapping.blank?
      messages[:error] << 'User must be assigned a role to be invited'
      return false
    end
    unless role_mapping.is_a?(Array) and role_mapping.size > 0
      messages[:error] << 'User must be assigned a role to be invited'
      return false
    end
    # checking validity of user team params
    team_mapping = invite_params[:team_mapping_attributes]
    if team_mapping.blank?
      messages[:error] << 'User must be assigned a manager and a finance manager to be invited'
      return false
    end
    unless team_mapping.is_a?(Array) and team_mapping.size > 0
      messages[:error] << 'User must be assigned a manager and a finance manager to be invited'
      return false
    end

  end

  def authorize
    # checking if role mapping attributes are compatible
    role_mapping = invite_params[:role_mapping_attributes]
    if user.manager?
      role_mapping.each do |role|
        rid = role[:user_role_id]
        unless rid.present? and (rid == UserRole.manager_id or rid == UserRole.employee_id)
          messages[:error] << "#{self.user.name} can only invite the user as an employee or manager"
          return false
        end
      end
    elsif user.finance_manager?
      role_mapping.each do |role|
        rid = role[:user_role_id]
        unless rid.present? and (rid == UserRole.finance_manager_id or rid == UserRole.employee_id)
          messages[:error] << "#{self.user.name} can only invite the user as an employee or finance manager"
          return false
        end
      end
    end

    # checking if team mapping attributes are compatible
    team_mapping = invite_params[:team_mapping_attributes]
    if self.user.manager? or self.user.finance_manager?

      default_present = false
      valid = false
      if self.user.manager?
        team_mapping.each do |mapping|
          if mapping[:default]
            default_present = true
          end
          if mapping[:manager_id].to_i == self.user.id
            valid = true
            break
          end
        end
      elsif self.user.finance_manager?
        team_mapping.each do |mapping|
          if mapping[:default]
            default_present = true
          end
          if mapping[:finance_manager_id].to_i == self.user.id
            valid = true
            break
          end
        end
      end
      unless default_present and valid
        messages[:error] << 'User can only be assigned to the inviting user'
        return false
      end
    end
  end

  def pre_process
    # if the user has a policy during invite, temporarily storing that user's policy to add it separately later
    if invite_params[:policy_id]
      @policy_id = invite_params[:policy_id]
      invite_params.delete(:policy_id)
    end
  end

  def process
    self.new_user = User.invite!(invite_params, self.user) do |u|
      # u.skip_invitation = true
    end
    unless new_user
      messages[:error] << "Invite failed. Try again!"
    end
  end

  def post_process
    # adding the user to the policy after he has been successfully invited
    if success?
      @policy = Policy.find_by(id: @policy_id)
      if @policy
        unless Policy::Users::AddUser.new(user, {policy_id: @policy.id, added_user_id: new_user.id})
          messages[:error] << "User could not be added to policy."
          return false
        end
      end
      messages[:success] = "User successdully invited."
    end
  end

end
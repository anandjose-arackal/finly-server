# action to invite a new user to the company
# types:
# email: comma separated emails
# mobile: comma separated mobile numbers

class User::Invite::Create < User::Invite::Base

  attr_accessor :invited_users, :emails, :numbers, :policy, :policy_id, :type

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'No user or param passed'
    end
  end

  def init
    self.invite_params = create_invite_params
    self.type = params[:invite_by]
    type == 'email' if type.nil?

    case type
      when 'mobile','1'
        self.numbers = invite_params[:mobile].delete(' ').split(',').collect(&:strip) rescue nil
        invite_params.delete(:mobile) # because mobile is not a field in the User model
        if self.numbers.present?
          self.numbers.compact!
          self.numbers.uniq!
        end
      when 'email','2'
        self.emails = invite_params[:email].delete(' ').split(',').collect(&:strip) rescue nil
        invite_params.delete(:mobile) # because mobile is not a field in the User model
        if self.emails.present?
          self.emails.compact!
          self.emails.uniq!
        end
      else
        # do nothing
    end
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

    if mobile_invite? and self.numbers.blank?
      messages[:error] << 'User email is required for inviting users'
      return false
    end

    if mobile_invite?
      violating_mobile_numbers = []
      self.numbers.each do |number|
        if (number =~ Constants::VALID_MOBILE_NUMBER).nil?
          messages[:error] << "#{number} is not a valid mobile number"
          return false
        end
        if User.find_by_mobile_number(number).present?
          violating_mobile_numbers << number
        end
      end
      if violating_mobile_numbers.present?
        messages[:error] << "Following numbers are already invited: #{violating_mobile_numbers.to_sentence}"
        return false
      end
      if has_errors?
        return false
      end
    end

    if email_invite?
      if email_invite? and self.emails.blank?
        messages[:error] << 'User email is required for inviting users'
        return false
      end

      violating_emails = []
      self.emails.each do |email|
        if (email =~ Constants::VALID_EMAIL_FORMAT).nil?
          messages[:error] << "#{email} is not a valid email format"
          return false
        end
        if User.find_by_email(email).present?
          violating_emails << email
        end
      end
      if violating_emails.present?
        messages[:error] << "Following emails are already invited: #{violating_emails.to_sentence}"
        return false
      end
      if has_errors?
        return false
      end
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
      messages[:error] << 'User must be assigned a team to be invited'
      return false
    end
    unless team_mapping.is_a?(Array) and team_mapping.size > 0
      messages[:error] << 'User must be assigned a team to be invited'
      return false
    end
  end


  def authorize
    # checking if role mapping attributes are compatible
    admin = user.company_admin?
    manager = user.manager?
    finance_manager = user.finance_manager?
    role_mapping = invite_params[:role_mapping_attributes]
    role_mapping.each do |role|
      rid = role[:user_role_id]
      if rid == UserRole.admin_id and not admin
        messages[:error] << "#{self.user.name} cannot invite a user as an admin"
        return false
      end
      if rid == UserRole.manager_id and not (manager or admin)
        messages[:error] << "#{self.user.name} cannot invite the user as an manager"
        return false
      end
      if rid == UserRole.finance_manager_id and not (finance_manager or admin)
        messages[:error] << "#{self.user.name} cannot invite the user as an manager"
        return false
      end
    end

    # checking if team mapping attributes are compatible
    team_mapping = invite_params[:team_mapping_attributes]
    if self.user.manager? or self.user.finance_manager?

      default_present = admin
      valid = admin

      if not admin and manager
        valid = false
        team_mapping.each do |mapping|
          if mapping[:default]
            default_present = true
          end
          if mapping[:manager_id].to_i == self.user.id
            valid = true
            break
          end
        end
      end
      if not admin and finance_manager
        valid = false
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
      self.policy_id = invite_params[:policy_id]
      invite_params.delete(:policy_id)
    end
    # adding the company's default policy to all invitation parameters
    invite_params[:team_mapping_attributes][0][:policy_id] = user.company.policies.default.first.id rescue nil
  end

  def process
    self.invited_users = []

    # if it's an email invite, use the same old technique of invitation
    if email_invite?
      emails.each do |email|
        invite_params[:email] = email
        invite_params[:first_name] = ''
        invite_params[:last_name] = ''
        self.invited_users << User.invite!(invite_params, self.user) do |u|
          u.invitation_note = params[:pending_invite][:note]
        end
      end
    elsif mobile_invite?
      numbers.each do |number|
        invite_params[:mobile_number] = number
        invite_params[:first_name] = ''
        invite_params[:last_name] = ''
        invite_params[:mobile_only_invite] = true

        self.invited_users << User.invite!(invite_params, self.user) do |u|
          u.skip_invitation = true
          u.update_attribute(:email, "")
        end
      end
      # send welcome message to all invited users
      CustomMessage::Create.(user, {mobile_number: numbers})
      # manually confirming everyone since there is no email by default and devise marks that as unconfirmed
      invited_users.each do |user|
        user.confirm
      end
    end

    if invited_users.empty?
      messages[:error] << 'Invites failed. Please try again'
    end
    
  end

  def post_process
    # adding the user to the policy after he has been successfully invited
    if success?
      self.policy = Policy.find_by(id: policy_id)
      if policy
        invited_users.each do |invited_user|
          unless Policy::Users::AddUser.new(user, {policy_id: policy.id, user_id: "#{invited_user.id}"}).run.success?
            messages[:error] << 'User could not be added to policy'
            return false
          end
        end
      end
      # adding the invitation note to the user
      messages[:success] << 'User successfully invited'
    end
  end

  private

  def mobile_invite?
    params[:invite_by] == 'mobile'
  end

  def email_invite?
    params[:invite_by] == 'email'
  end

end
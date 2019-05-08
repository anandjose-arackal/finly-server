class User::Invite::CreateVp < User::Invite::Base

  attr_accessor :invited_users, :emails, :numbers, :policy, :policy_id, :type, :policy_roles, :admin

  def pre_validate
    if params.blank? or user.blank?
      messages[:error] << 'No user or params passed'
    end
  end

  def init
    self.invite_params = create_invite_params
    self.type = params[:invite_by]
    self.policy_roles = params[:roles]
    if params[:policy_id]
      self.policy_id = params[:policy_id]
      invite_params.delete(:policy_id)
    end
    self.admin = self.policy_roles.include?("admin")
    self.policy_roles = self.policy_roles - ["admin"]

    type == 'email' if type.nil?
    case type
      when 'mobile', '1'
        self.numbers = invite_params[:mobile].delete(' ').split(',').collect(&:strip) rescue nil
        invite_params.delete(:mobile) # because mobile is not a field in the User model
        if self.numbers.present?
          self.numbers.compact!
          self.numbers.uniq!
        end
      when 'email', '2'
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

    # if mobile_invite?
    #   violating_mobile_numbers = []
    #   self.numbers.each do |number|
    #     if (number =~ Constants::VALID_MOBILE_NUMBER).nil?
    #       messages[:error] << "#{number} is not a valid mobile number"
    #       return false
    #     end
    #     if User.find_by_mobile_number(number).present?
    #       violating_mobile_numbers << number
    #     end
    #   end
    #   if violating_mobile_numbers.present?
    #     messages[:error] << "Following numbers are already invited: #{violating_mobile_numbers.to_sentence}"
    #     return false
    #   end
    #   if has_errors?
    #     return false
    #   end
    # end

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
    role_mapping = params[:roles]
    if role_mapping.blank?
      messages[:error] << 'User must be assigned a role to be invited'
      return false
    end
    unless role_mapping.is_a?(Array) and role_mapping.size > 0
      messages[:error] << 'User must be assigned a role to be invited'
      return false
    end

    if self.policy_id.blank?
      add_message :error, "User must belong to a particular policy during invitation"
      return
    end
  end


  def authorize
    # checking if role mapping attributes are compatible
    unless user.vendor_payments_admin?
      add_message :error, "Only admins can invite new users to the system"
      return
    end
  end

  def configure_expense_management
    invite_params[:user_panel_subscription_attributes] = {expense_management: true}
    invite_params.permit!
  end

  def configure_disburse
    invite_params[:user_panel_subscription_attributes] = {disburse: true}
    invite_params.permit!
  end

  def configure_vendor_payment
    invite_params[:user_panel_subscription_attributes] = {yes_bank_account_transfer: true}
    invite_params.permit!
  end

  def pre_process

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
          self.policy_roles.each do |role|
            u.policy_user_roles.build(user_role_id: UserRole.id_for(role.to_sym), policy_id: self.policy_id)
          end
          u.role_mapping.build(user_role_id: UserRole.id_for(:initiator), purpose_id: Purpose.id_for(:vendor_payments))
          if self.admin
            u.role_mapping.build(user_role_id: UserRole.id_for(:admin), purpose_id: Purpose.id_for(:vendor_payments))
          end
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
      # CustomMessage::Create.(user, {mobile_number: numbers})
      Sms::UserInvite.(user)
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
    add_message :success, "User(s) successfully invited!"
  end

  private

  def mobile_invite?
    params[:invite_by] == 'mobile'
  end

  def email_invite?
    params[:invite_by] == 'email'
  end

  def create_invite_params_vp
    params.require(:pending_invite).permit(:email, :mobile, :mobile_number, :company_id, :policy_id)
  end

end
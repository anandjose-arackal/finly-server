class User::Delegate::Update < User::Base

  attr_accessor :delegated_user, :selected_user, :role_id,
                :delegation_enabled, :purpose_id

  def init
    delegated_user_id = params[:user_delegate_id]
    self.delegated_user = user.company.users.find_by(id: delegated_user_id)
    id = params[:id] || params[:user_id]
    self.role_id = UserRole::VALUES[params[:view].to_sym]
    case self.role_id
      when UserRole.id_for(:admin)
        self.selected_user = user.company.users.find_by(id: id)
      when UserRole.id_for(:employee)
        self.selected_user = user
      else
        self.selected_user = user
    end
    self.purpose_id = Purpose.id_from_application_for(RequestStoreUtil.current_app)
    self.delegation_enabled = StringUtils.to_bool(params[:delegation_enabled])
  end

  def validate
    if self.delegation_enabled
      if self.delegated_user.blank?
        add_message :error, "You have to set a delegated user if enabling this feature"
        return
      end

      # also ensure that whatever roles is present with the selected user
      # is also present with the delegated user
      delegated_user_roles = self.delegated_user.role_mapping.reviewer_mappings_only.with_purpose(self.purpose_id).pluck(:user_role_id).uniq
      selected_user_roles = self.selected_user.role_mapping.reviewer_mappings_only.with_purpose(self.purpose_id).pluck(:user_role_id).uniq
      unless (selected_user_roles - delegated_user_roles).empty?
        add_message :error, "Please ensure that the delegated user has the same roles as the present user"
        return
      end
    end
  end

  def process
    unless self.selected_user.update(user_delegate: self.delegated_user, delegation_enabled: self.delegated_user.present?)
      add_message :error, self.selected_user.errors.full_messages
    end
  end

  def post_process
    add_message :success, "New User delegate added!"
  end
end
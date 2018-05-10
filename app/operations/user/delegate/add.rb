class User::Delegate::Add < User::Base

  attr_accessor :delegated_user, :selected_user, :role_id

  def authorized_user_types
    [:company_admin, :employee]
  end

  def init
    delegated_user_id = params[:delegated_user_id]
    self.delegated_user = user.company.users.find_by(id: delegated_user_id)
    id = params[:id] || params[:user_id]
    self.role_id = UserRole::VALUES[params[:view].to_sym]
    case self.role_id
      when UserRole.id_for(:admin)
        self.selected_user = user.company.users.find_by(id: id)
      when UserRole.id_for(:employee)
        self.selected_user = user
      else
        # do nothing?
    end
    self.purpose_id = Purpose.id_from_application_for(RequestStoreUtil.current_app)
  end

  def validate
    unless self.delegated_user.present?
      add_message :error, "Delegated user not found"
      return
    end
  end

  def process
    if self.selected_user.update(user_delegate: self.delegated_user)
      # ensuring the user being delegated to has all the required roles to execute the respective
      # actions - so essentially adding
      user_roles = self.selected_user.role_mapping.with_purpose(self.purpose_id).pluck(:user_role_id)
      delegated_user_roles = self.delegated_user.role_mapping.with_purpose(self.purpose_id).pluck(:user_role_id)
      new_roles = user_roles - delegated_user_roles
      new_roles.each do |new_role|
        self.delegated_user.role_mapping.build(purpose_id: self.purpose_id, user_role_id: new_role).save
      end
    end
  end

  def post_process
    add_message :success, "New User delegate added!"
  end
end
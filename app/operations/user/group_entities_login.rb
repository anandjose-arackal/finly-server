class User::GroupEntitiesLogin < User::Base

  attr_accessor :email_mobile, :companies, :email, :mobile_number, :group

  def init
    self.email_mobile = params[:email_mobile]
    self.user = User.find_for_database_authentication(username: self.email_mobile)
    self.company = self.user&.company
  end

  def validate
    if user.blank?
      add_message :error, "User not found"
      return
    end

    if self.company.blank?
      add_message :error, "Company not found"
      return
    end

    unless user.company.group_entity_structure_enabled?
      add_message :error, "Your corporate doesn't have group entity feature enabled"
      return
    end
  end

  def process

  end

  def success

  end

end
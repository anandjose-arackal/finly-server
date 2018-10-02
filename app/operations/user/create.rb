# Used to create users without invitation
class User::Create < Admin::Users::Create

  def authorized_user_types
    [:company_admin]
  end

  def pre_validate
    # Overriding admin user create operation's behaviour

  end



end
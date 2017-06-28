# Used to create users without invitation
class User::CreateWoPassword < Admin::Users::Create
  def pre_validate
    # Overriding admin user create operation's behaviour
    params[:user][:password] = rand(36**8).to_s(36)
  end
end
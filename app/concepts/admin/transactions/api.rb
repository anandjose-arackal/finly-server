class Admin::Transactions::API < Transactions::API

  user_model AdminUser

  def self.AssignAdminModelUser(key: :admin_user)
    Transactions::Task.build id: "assign_model_user" do |context, **|
      context[:model].send("#{key}=", context[:current_user])
      true
    end
  end

end
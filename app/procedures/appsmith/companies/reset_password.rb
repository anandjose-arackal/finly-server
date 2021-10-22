class Appsmith::Companies::ResetPassword < Transactions::API

    schema do
        params do
          required(:set_password)
          required(:users_data).array do
            hash do
              required(:company_id)
              required(:user_id)
            end
          end
        end
    end
    

    user_model(AdminUser)
    #this feature must not work in production so this function
    step :verify_non_prod_environment
    #this function reset all(uat) users password
    step :reset_password
 
    def verify_non_prod_environment(context, **)
      return unauthorized!(context) if Rails.env.production?
      true
    end

    def reset_password(context, params:, **)
        if params[:set_password].blank? or params[:users_data].blank?
            #if appsmith user(s) by mistake edit the settings in appsmith then this function will check for empty password and users
            context[:error] = "password must not blank or users must be selected"
            return true
        else
            params[:users_data].each do |user|
                ActsAsTenant.current_tenant = Company.find(user[:company_id])
                context[:user_data] =  Company.find(user[:company_id]).users.find(user[:user_id])
                context[:user_data].password = params[:set_password]
                context[:user_data].otp_verified = true
                context[:user_data].default_password = false
                context[:user_data].save validate: false
            end
            context[:success] = "Password reset successfully"
            return true
        end
    end
end

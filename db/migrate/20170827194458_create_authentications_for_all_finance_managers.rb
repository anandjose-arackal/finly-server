class CreateAuthenticationsForAllFinanceManagers < ActiveRecord::Migration[4.2]
  def change
    Authentication.with_provider('quickbooks').each do |auth|
      user = auth.user
      # adding all finance managers in the company
      finance_managers = user.company.users.only_finance_managers
      finance_managers.each do |fm|
        auth_obj = fm.authentications.with_provider(auth.provider).first
        if auth_obj.present?
          auth_obj.update(uid: auth.uid, token: auth.token, secret: auth.secret, expires_at: 180.days.from_now)
        else
          fm.authentications.build(provider: auth.provider, uid: auth.uid, token: auth.token, secret: auth.secret, expires_at: 180.days.from_now).save
        end
      end
      admins = user.company.users.only_admins
      admins.each do |admin|
        auth_obj = admin.authentications.with_provider(auth.provider).first
        if auth_obj.present?
          auth_obj.update(uid: auth.uid, token: auth.token, secret: auth.secret, expires_at: 180.days.from_now)
        else
          admin.authentications.build(provider: auth.provider, uid: auth.uid, token: auth.token, secret: auth.secret, expires_at: 180.days.from_now).save
        end
      end
    end
  end
end

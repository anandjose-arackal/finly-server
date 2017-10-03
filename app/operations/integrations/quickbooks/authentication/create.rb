class Integrations::Quickbooks::Authentication::Create < BaseOperation

  attr_accessor :auth, :user_auth

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
    end
  end

  def init
    self.auth = params[:omniauth]
    self.user_auth = user.authentications.where(provider: auth[:provider]).first
  end

  def process
    # adding this authentication for all finance managers, auditors and admins in the company so that anyone can sync reports with quickbooks
    finance_managers = user.company.users.only_finance_managers
    finance_managers.each do |fm|
      auth_obj = fm.authentications.with_provider(auth[:provider]).first
      if auth_obj.present?
        auth_obj.update(uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now)
      else
        fm.authentications.build(provider: auth[:provider], uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now).save
      end
    end
    admins = user.company.users.only_admins
    admins.each do |admin|
      auth_obj = admin.authentications.with_provider(auth[:provider]).first
      if auth_obj.present?
        auth_obj.update(uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now)
      else
        admin.authentications.build(provider: auth[:provider], uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now).save
      end
    end
    auditors = user.company.users.only_auditors
    auditors.each do |auditor|
      auth_obj = auditor.authentications.with_provider(auth[:provider]).first
      if auth_obj.present?
        auth_obj.update(uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now)
      else
        auditor.authentications.build(provider: auth[:provider], uid: auth[:uid], token: auth[:credentials][:token], secret: auth[:credentials][:secret], expires_at: 180.days.from_now).save
      end
    end
  end

  def post_process
    add_message :success, "You have successfully linked your Quickbooks account with Finly"

    # fetching the payment types for this company and storing it in the database
    Integrations::Quickbooks::SyncPaymentTypes.(user.company, params, user)

    # creating a quickbooks configuration account for this particulat company
    if user.company.quickbooks_configuration.nil?
      user.company.build_quickbooks_configuration(default_quickbooks_payment_type: "Cash").save
    end
  end
end
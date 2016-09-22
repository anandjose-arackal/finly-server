class DeviseMailer < Devise::Mailer
  # helper :application # gives access to all helpers defined within `application_helper`.
  # include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def confirmation_instructions(record, token, opts={})
    # EventHandler.new_company_signup record, token
  end

  def reset_password_instructions(record, token, opts={})
    UserMailer.password_reset_instructions record, token
  end

  def unlock_instructions(record, token, opts={})
    UserMailer.account_unlock_instructions record, token
  end

  def password_change(record, opts={})
    UserMailer.password_changed record
  end

  def invitation_instructions(record, token, opts={})
    UserMailer.invite(record, token)
  end

end

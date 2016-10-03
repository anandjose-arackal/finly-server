class DeviseMailer < Devise::Mailer
  # helper :application # gives access to all helpers defined within `application_helper`.
  # include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`

  def confirmation_instructions(record, token, opts={})
    # EventHandler.new_company_signup record, token
  end

  def reset_password_instructions(record, token, opts={})
    UserMailer.delay.password_reset_instructions(record, token)
  end

  def unlock_instructions(record, token, opts={})
    UserMailer.delay.account_unlock_instructions(record, token)
  end

  def password_change(record, opts={})
    UserMailer.delay.password_changed(record)
  end

  def invitation_instructions(record, token, opts={})
    note = record.invitation_note
    UserMailer.delay.invite(record, token, note)
  end

end

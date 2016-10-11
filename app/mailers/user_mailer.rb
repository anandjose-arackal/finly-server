class UserMailer < ApplicationMailer
  # default from: 'server@hapitoe.com'

  def account_activation_instructions(user, token)
    @user = user
    @token = token
    mail to: user.email, subject: 'Account activation'
  end

  def password_reset_instructions(user, token)
    @user = user
    @token = token
    mail to: user.email, subject: 'Password reset instructions'
  end

  def password_changed(user)
    @title = "Password changed successful!"
    @body = "You have successfully changed your password.\n\nIf this was not initiated by you, please contact your company admin right away.".gsub(/\n/, '<br/>').html_safe
    mail to: user.email, subject: 'Password reset instructions'
  end

  def account_unlock_instructions(user, token)
    @user = user
    @token = token
    mail to: user.email, subject: 'Account locked'
  end

  def welcome(user)
    mail to: user.email, subject: 'Welcome to Finly!'
  end

  def invite(user, token, note)
    @user = user
    @token = token
    @note = note
    mail to: user.email, subject: 'Invitation to use Finly!'
  end

  def role_updated(user)
    if user.admin?
      @title = "You are now an Admin"
      @body = "As an admin, you have complete control over all the users and their expenses in the company, from reviewing expenses to setting rules to settlements"
    elsif user.manager?
      @title = "You are now a manager"
      @body = "As a manager, you can approve or deny the reports of people you manage."
    elsif user.finance?
      @title = "You are now a finance manager"
      @body = "As a finance manager, you can approve or deny the reports of people you manage."
    elsif user.employee?
      @title = "Your role has now been updated as an employee"
    end
    mail to: user.email, subject: 'Invitation to use TnE Management!'
  end

  def manager_updated(user, manager)
    if manager.blank?
      @title = "You currently have no manager to manage your accounts"
      @body = "All your expenses will be auto approved"
    else
      @title = "#{manager.name} has been assigned as your manager"
      @body = "All your expenses will be approved by #{manager.name} henceforth"
    end
    mail to: user.email, subject: 'You have been assigned to a new manager'
  end

end

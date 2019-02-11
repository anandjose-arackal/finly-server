class EmailAuthorizations::Invalidate < EmailAuthorizations::Base
  attr_accessor :authorizable, :email_authorization

  def init
    self.authorizable = params[:authorizable]
    unless authorizable.present?
      add_message :error, "Authorizable not provided."
      return
    end
    self.email_authorization = EmailAuthorization.with_authorizable(authorizable)
  end

  def process
    transaction = email_authorization.update_all({is_valid: false})
    unless transaction
      add_message :error, "Updating Email Authorization Failed"
    end
  end

  def post_process

  end
end
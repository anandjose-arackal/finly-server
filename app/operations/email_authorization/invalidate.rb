class EmailAuthorization::Invalidate < EmailAuthorization::Base
  attr_accessor :authorizable, :email_authorizations

  def init
    self.authorizable = params[:authorizable]
    unless authorizable.present?
      add_message :error, "Authorizable not provided."
      return
    end
    self.email_authorizations = EmailAuthorization.with_authorizable(authorizable)
  end

  def process
    transaction = email_authorizations.update_all({is_valid: false})
    unless transaction
      add_message :error, "Updating Email Authorizatio Failed"
    end
  end

  def post_process

  end
end
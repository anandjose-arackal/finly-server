class EmailAuthorization::Create < EmailAuthorization::Base
  attr_accessor :authorizable, :token, :email_authorization
  def init
    self.authorizable = params[:authorizable]
    unless authorizable.instance_of?(Report) || authorizable.instance_of?(MoneyRequest)
      add_message :error, "Wrong Authorizable type provided."
      return
    end

    user_id = authorizable.controlling_user_id
    view_role_id = authorizable.controlling_user_role_id
    e_auth = EmailAuthorization.with_user_id(user_id).with_authorizable(authorizable).with_view_role_id(view_role_id).limit(1)
    self.email_authorization = e_auth&.first
  end

  def validate
    unless authorizable.processing?
      add_message :error, "Cannot create authorization when authorizable is not in processing state."
    end
  end

  def process
    unless self.email_authorization
      self.token = nil
      loop do
        self.token = Digest::SHA1.hexdigest([Time.now, rand].join)
        break unless EmailAuthorization.with_token(self.token).present?
      end

      self.email_authorization = EmailAuthorization.new(
        user_id: authorizable.controlling_user_id,
        authorizable: authorizable,
        view_role_id: authorizable.controlling_user_role_id,
        token: token
      )
      unless self.email_authorization.save
        add_message :error, "Couldn't save."
      end
    else
      self.email_authorization.update_attributes(is_valid: true)
    end
    
  end

  def post_process
  end

  def success
    params[:email_authorization] = self.email_authorization
    EmailAuthorization::Create::Presenter.new(user, params, messages)
  end

  class EmailAuthorization::Create::Presenter < BaseOperation::BasePresenter::SuccessPresenter
    attr_accessor :email_authorization

    def init
      self.email_authorization = params[:email_authorization]
    end

  end
end
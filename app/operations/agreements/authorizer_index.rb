class Agreements::AuthorizerIndex < Admin::Agreement::Index
  def pre_validate
    token = params[:token]

    self.email_authorization = EmailAuthorization.with_token(token).with_valid.first
    unless email_authorization.present?
      add_message :error, 'Invalid/Expired Token'
      return
    end
  end
end
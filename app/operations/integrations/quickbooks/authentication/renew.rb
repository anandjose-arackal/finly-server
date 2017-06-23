class Integrations::Quickbooks::Authentication::Renew < BaseOperation

  attr_accessor :auth_object

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters, try again"
    end
  end

  def init
    self.auth_object = user.authentications.quickbooks.first
  end

  def process
    access_token = OAuth::AccessToken.new(QB_OAUTH_CONSUMER, auth_object.token, auth_object.secret)
    service = Quickbooks::Service::AccessToken.new
    service.access_token = access_token
    service.company_id = auth_object.uid # because the uid is the unique id given to a particular entity on Quickbooks
    new_token = service.renew # the method that refreshes the access token through the quickbooks API

    case new_token.error_code
      when "0" # Success
        # Update the stored values
        unless auth_object.update_attributes(
            access_token: new_token.token,
            access_secret: new_token.secret,
            token_expires_at: 180.days.from_now.utc)
          add_message :error, auth_object.errors.full_messages
        end
        add_message :success, "Renewal succeeded"
      when "270" # The OAuth access token has expired.
        # Discard any saved credentials, need to restart the OAuth process
        record.update_attributes(
            access_token: nil,
            access_secret: nil,
            token_expires_at: nil,
        )
        add_message :error, "Renewal failed because the token has expired"
      when "212" # Token Refresh Window Out of Bounds
        # Tried to renew it more than 30 days before expiration
        add_message :error, "You cannot renew a token more than 30 days before the date of expiry"
      else
        add_message :error, "Renewal failed, code: #{new_token.error_code} message: #{new_token.error_message}"
    end
  end

  def post_process

  end

  def success

  end

end
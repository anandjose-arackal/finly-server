class BaseControllers::AdminBase < ApplicationController
  authentication_scope :admin

  def set_tokens_in_header
    if self.class.required_header_token_actions.include?(action_name)
      access_token = request.cookies['access_token_admin']
      if access_token.present?
        request.headers['Authorization'] = "Bearer #{access_token}"
      end
    end
  end
end

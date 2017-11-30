class RequestFormatter::VirtualBankAccountParser::Parse < RequestFormatter::Base

  def validate
    if user.blank?
      add_message :error, 'User not found'
      return
    end
    if params.blank?
      add_message :error, 'Error loading configuration'
    end
  end

  def process
    map = format_file(__dir__, 'virtual_bank_account.yaml.erb', user, params)

    Formatter.handle_api_nil map

    self.formatted_request = map
  end
end
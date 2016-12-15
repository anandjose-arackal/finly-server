class ItzCash::Base < BaseHandler
  attr_accessor :response_code, :parsed_response

  def parse
    self.parsed_response = self.response.body.split(',') rescue []
    self.response_code = parsed_response[0] if self.parsed_response.present?
  end

  def success_response_code
    [0]
  end

  def success?
    super and self.response_code.present? and (success_response_code.include?(self.response_code.to_f))
  end

  def failure
    if response_code.present? and not response_code.to_i == 0 and messages[:error].blank?
      error_message = Constants::ItzCash::ERROR_CODES[response_code.to_i]
      error_message = 'Unknown error while performing the action' if error_message.blank?
      add_message :error, error_message
    end
    super
  end

end
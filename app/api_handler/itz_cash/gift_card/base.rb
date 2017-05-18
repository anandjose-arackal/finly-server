class ItzCash::GiftCard::Base < ItzCash::Dmt::Base

  def env_key
    'virtual_gift_card'
  end

  def transaction_id
    'transaction_id'
  end

  def success?
    return false unless super
    if self.parsed_response.present?
      response_code = HashUtils.nested_search self.parsed_response, :responseMessage
      if response_code.present? and response_code == '0'
        return true
      end
    end
    false
  end

  def failure
    response_desc = HashUtils.nested_search self.parsed_response, :responseMessage
    add_message :error, response_desc
    super
  end

end
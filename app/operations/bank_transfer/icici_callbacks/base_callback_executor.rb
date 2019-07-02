# this class will contain the majority of the decrypting request and sending it to
# the respective Callback executor

class BankTransfer::IciciCallbacks::BaseCallbackExecutor < BaseOperation

  def initialize(encrypted_string)

  end

  def self.call(encrypted_string)
    decrypted_params = decrypt_request(encrypted_string)
    if decrypted_params["STATUS"].present?
      # this is the registration callback to initialize that operation and run it
      obj = BankTransfer::IciciCallbacks::RegistrationCallbackExecutor.new(decrypted_params)
    elsif decrypted_params["TXNSTATUS"].present?
      obj = BankTransfer::IciciCallbacks::TransactionCallbackExecutor.new(decrypted_params)
    else
      # this is an anomaly, return an error
      add_message :error, "Unknown callback type"
      obj = nil
    end
    obj&.run
  end

  private

  def decrypt_request(encrypted_string)
    # todo - same logic for decryption as in the response parsing inside ICICI/Base
    decrypted_params = {}
    parsed_request = JSON.parse(decrypted_params)
  end

end

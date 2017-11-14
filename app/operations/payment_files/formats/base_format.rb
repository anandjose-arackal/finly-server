# Expected format
# {
#     payment_file: [
#         {
#             email: 'email@id.com',
#             mobile_number: '9989989898',
#             bank_account: '<bank_account>',
#             amount: <amount class>,
#         }
#     ]
# }
class PaymentFiles::Formats::BaseFormat < BaseOperation
  attr_accessor :payment_file_data, :config, :options

  def pre_validate
    if params&.dig(:payment_file).nil?
      add_message :error,'Payment data not found'
      return
    end
  end

  def init
    self.payment_file_data = params[:payment_file]
    self.config = user.company.payment_file_configuration
    self.options = self.config&.options
  end

  def validate
    if self.payment_file_data.nil?
      add_message :error,'Payment data not found'
      return
    end
    self.payment_file_data.each do |data|
      unless data[:bank_account].present? and data[:bank_account].class.name == BankAccount.name
        add_message :error, 'Invalid Data: Bank Account not found'
        return
      end
      unless data[:amount].present? and data[:amount].class.name == Amount.name
        add_message :error, 'Invalid Data: Amount not valid'
        return
      end
    end
  end

end
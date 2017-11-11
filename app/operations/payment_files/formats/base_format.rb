# Expected format
# {
#     payment_file: [
#         {
#             user: '<user>',
#             amount: 150,
#             currency_id: 1
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
      unless data[:user].present? and data[:user].class.name == User.name
        add_message :error, 'Invalid Data: User not found'
        return
      end
      unless data[:amount].present? and data[:amount]&.to_d > 0
        add_message :error, 'Invalid Data: Amount not valid'
        return
      end
      unless data[:currency_id].present?
        add_message :error, 'Invalid Data: Currency not valid'
        return
      end
    end
  end

end
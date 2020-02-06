class Admin::Implementations::Master::BBPS::Import < Admin::Implementations::Processor::Import

  class Contract < Docs::UtilityBills::Subscriptions::Contracts::Base

    property :company
    property :category, deserializer: -> (input, represented, **) do
      represented.category = represented.company.categories.find_by(name: input[:category_id])
    end
    property :user, deserializer: -> (input, represented, **) do
      represented.user = represented.company.users.find_by(email: input[:initiator])
    end
    property :biller, deserializer: -> (input, represented, **) do
      represented.biller = BbpsBiller.find_by(biller_id: input[:biller_id])
    end
    property :mobile_number

    property :customer_param_key_1, deserializer: -> (input, represented, **) do
      represented.customer_param_key_1 = represented.biller&.biller_customer_params[0]&.dig('param_name')
    end

    property :customer_param_value_1

    property :customer_param_key_2, deserializer: -> (input, represented, **) do
      represented.customer_param_key_1 = represented.biller&.biller_customer_params[1]&.dig('param_name')
    end

    property :customer_param_value_2

    property :customer_param_key_3, deserializer: -> (input, represented, **) do
      represented.customer_param_key_1 = represented.biller&.biller_customer_params[2]&.dig('param_name')
    end

    property :customer_param_value_3

    property :customer_param_key_4, deserializer: -> (input, represented, **) do
      represented.customer_param_key_1 = represented.biller&.biller_customer_params[3]&.dig('param_name')
    end
    property :customer_param_value_4

    property :customer_param_key_5, deserializer: -> (input, represented, **) do
      represented.customer_param_key_1 = represented.biller&.biller_customer_params[4]&.dig('param_name')
    end

    property :customer_param_value_5

  end

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bank_accounts.import'
  headers({
              :initiator => "Initiator / Creator of Subscription*",
              :category_id => "Category (for Reference) [Optional]",
              :biller_id => "Biller ID*",
              :biller_name => "Biller Name (for Reference) [Optional]",
              :mobile_number => "Associated Mobile Number*",
              :customer_param_value_1 => "Custom Param 1",
              :customer_param_value_2 => "Custom Param 2",
              :customer_param_value_3 => "Custom Param 3",
              :customer_param_value_4 => "Custom Param 4",
              :customer_param_value_5 => "Custom Param 5",
              :location => "Location*",
              :department => "Department",
              :cost_center => "Cost Center",
              :policy => "Policy*",
              :poc => "POCs Email(Separated by commas)*",
              :destroy => "Destroy"
          })
  attr_accessor :bank_account_params

  def create_record(data)
    bank_account_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    user = bank_account_params[:user]
    bank_account = user.bank_accounts.new bank_account_params.except(:user)
    unless bank_account.save
      return result false, bank_account.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    bank_account_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end
    user = bank_account_params[:user]
    bank_account = user.bank_accounts.find_by id: data[:id]
    unless bank_account
      return result false, "Bank Account not found"
    end

    unless bank_account.update(bank_account_params.except(:user))
      return result false, bank_account.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
    bank_account_params, messages = set_params(data)

    unless messages.blank?
      return result false, messages.join(', ')
    end

    user = bank_account_params[:user]
    bank_account = user.bank_accounts.find_by id: data[:id]
    unless bank_account
      return result false, "Bank Account not found"
    end

    begin
      unless bank_account.destroy
        return result false, bank_account.errors.full_messages
      end
    rescue Exception => e
      return result false, "#{e.message}"
    end

    result true, "Destroyed Successfully"
  end

  def set_params(data)
    messages = []
    name = data[:name].to_s
    user_id = clean_up_data data[:user_id]
    user_entity = get_user_entity user_id
    unless user_entity.present?
      messages << "User Not Found"
    end
    account_number = clean_up_data data[:account_number]
    account_number.is_a?(String) ? account_number.gsub!("'", "") : ''
    ifsc = data[:ifsc]
    params = {
        name: name,
        user: user_entity,
        account_number: clean_up_data(account_number),
        ifsc: ifsc
    }
    [params, messages]
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.to_s.strip
    end
  end

  def get_user_entity(identifier)
    user = nil
    if Constants::VALID_EMAIL_FORMAT.match?(identifier)
      user = company.users.find_by_email identifier
    elsif Constants::VALID_MOBILE_NUMBER.match?(identifier)
      user = company.users.find_by_mobile_number identifier
    end
    user
  end

end


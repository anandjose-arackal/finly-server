class Admin::Implementations::Master::BankAccounts::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'bank_account.import'
  headers [
               :account_name,
               :user_id,
               :account_number,
               :ifsc
           ]
  attr_accessor :bank_account_params
  def create_record(data)
    bank_account_params, messages = set_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end

    bank_account = self.company.bank_accounts.new bank_account_params
    unless bank_account.save
      return result false, bank_account.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    bank_account = self.company.bank_accounts.find_by id: data[:id]
    unless bank_account
      return result false, "bank_account not found"
    end

    unless bank_account.update(data.except(:destroy))
      return result false, bank_account.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   bank_account = self.company.bank_accounts.find_by id: data[:id]
   unless bank_account
    return result false, "bank_account not found"
   end
   unless bank_account.destroy
     return result false, bank_account.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end

  def set_params(data)
    messages = []
    name = data[:name].to_s
    user_id = clean_up_data data[:user_id]
    user_entity = company.users.where(mobile_number: data[:user_id]).or(company.users.where(email: data[:user_id])).first
    unless user_entity.present?
       messages << "User Not Found"
    end
    account_number = clean_up_data data[:account_number]
    ifsc = data[:ifsc]
    params = {
        name: name,
        user_id: user_entity&.id,
        account_number: account_number,
        ifsc: ifsc
    }
    [params, messages]
  end

  def clean_up_data(text)
    if text.is_a?(Float) || text.is_a?(Integer)
      text.to_i.to_s
    else
      text.strip
    end
  end

end


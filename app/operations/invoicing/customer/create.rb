class Invoicing::Customer::Create < Invoicing::Customer::Base

  attr_accessor :customer, :customer_params, :company, :virtual_account_numbers

  def init
    self.company = user.company
    self.customer_params = customer_parameters
    self.virtual_account_numbers = []
  end


  def pre_process
    # check if the customer wants a virtual account created, and if so, create one from Finly Collect
    if StringUtils.to_bool(self.customer_params[:create_virtual_account])
      if self.customer_params[:virtual_bank_accounts_attributes].blank?
        add_message :error, "Virtual bank accounts data invalid"
        return
      end
      self.customer_params[:virtual_bank_accounts_attributes].each do |data|
        op = FinlyCollect::Create.(user, {})
        if op.success?
          self.virtual_account_numbers << op.account_number
          va_number = op.account_number
          name = data[:name] || "Virtual Account"
          # now add this to the customer parameters so that on creation it is linked to this customer
          data.merge!({
              account_number: va_number,
              ifsc: Constants::YesBank::YES_BANK_COLLECT_IFSC,
              application: current_app,
              initiating_user: user,
              company_id: user.company_id,
              receiving_account: user.company.yes_bank_company_account,
              default_account: true,
              name: name,
              purpose_id: VirtualAccountPurpose.id_for(:virtual_bank_account) # this is because as of now it isn't attached to an invoice or payment receivable, which will be determined later
          })
        else
          # in this case Finly Collect responded with a failure, so do nothing?
          # Probably trigger a mailer or something IDK
        end
      end
    else
      self.customer_params.delete(:virtual_bank_accounts_attributes)
    end
    # delete the 'create_virtual_account' key irrespective
    self.customer_params.delete(:create_virtual_account)

    # add details of the user who's creating the customer
    # self.customer_params[:created_by_id] = self.user.id
  end


  def process
    self.customer = self.company.customers.build(self.customer_params)
    unless self.customer.save
      # delete the virtual accounts that were created for this company if it's present
      if self.virtual_account_numbers.present?
        self.virtual_account_numbers.each do |account_number|
          FinlyCollect::Destroy.(user, account_number: account_number)
        end
        Event::EAlert::Create.(nil, title: 'Finly Collect Account created in collect server but failed to created in app',
            description: "#{self.virtual_account_numbers.to_sentence}<br><br>Errors : #{self.customer.errors.full_messages}",
            subject: 'Finly Collect - Failed to create account in app')
      end
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer successfully created"
  end

end
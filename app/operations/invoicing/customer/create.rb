class Invoicing::Customer::Create < Invoicing::Customer::Base

  attr_accessor :customer, :customer_params, :company, :virtual_account_number

  def init
    self.company = user.company
    self.customer_params = customer_parameters
  end


  def pre_process
    # check if the customer wants a virtual account created, and if so, create one from Finly Collect
    if StringUtils.to_bool(self.customer_params[:create_virtual_account])
      op = FinlyCollect::Create.(user, {})
      if op.success?
        self.virtual_account_number = op.account_number
        # now add this to the customer parameters so that on creation it is linked to this customer
        self.customer_params[:virtual_account_attributes] = {
            account_number: self.virtual_account_number,
            ifsc: Constants::YesBank::YES_BANK_COLLECT_IFSC,
            application: current_app,
            initiating_user: user,
            company_id: user.company_id,
            receiving_account: user.company.yes_bank_company_account,
            default_account: true
        }
      else
        # in this case Finly Collect responded with a failure, so do nothing?
        # Probably trigger a mailer or something IDK
      end
    end
  end


  def process
    self.customer = self.company.customers.build(self.customer_params)
    unless self.customer.save
      # delete the virtual account that was created for this company if it's present
      if self.virtual_account_number.present?
        FinlyCollect::Destroy.(user, account_number: self.virtual_account_number)
        Event::EAlert::Create.(nil, title: 'Finly Collect Account created in collect server but failed to created in app',
            description: "#{self.virtual_account_number}<br><br>Errors : #{self.customer.errors.full_messages}",
            subject: 'Finly Collect - Failed to create account in app')
      end
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer successfully created"
  end

end
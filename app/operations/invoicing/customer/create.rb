class Invoicing::Customer::Create < Invoicing::Customer::Base

  attr_accessor :customer, :customer_params, :company, :virtual_account_details, :create_virtual_account

  class Invoicing::Customer::Create::CustomerPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :customer

    def init
      self.customer = params[:customer]
    end
  end

  def init
    self.company = user.company
    self.customer_params = customer_parameters
    self.virtual_account_details = []
  end


  def pre_process
    # check if the customer wants a virtual account created, and if so, create one from Finly Collect
    if StringUtils.to_bool(self.customer_params[:create_virtual_account])
      if self.customer_params[:virtual_bank_accounts_attributes].blank?
        add_message :error, "Virtual bank accounts data invalid"
        return
      end
      self.create_virtual_account = true
      self.customer_params[:virtual_bank_accounts_attributes].each do |data|
        self.virtual_account_details << {
            name: data[:name]
        }
      end
      self.customer_params.delete(:virtual_bank_accounts_attributes)
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
    if self.customer.save
      if self.create_virtual_account

        # create the virtual accounts that were required by this particular customer
        self.virtual_account_details.each do |details|
          op = FinlyCollect::Create.(user, {})
          if op.success?
            va_number = op.account_number
            name = details[:name] || "Virtual Account"
            # creating the hash for assigning the virtual bank accounts
            attributes = {
                            account_number: va_number,
                            ifsc: Constants::YesBank::YES_BANK_COLLECT_IFSC,
                            application: current_app,
                            initiating_user: user,
                            company_id: user.company_id,
                            receiving_account: user.company.yes_bank_company_account,
                            default_account: true,
                            name: name,
                            purpose_id: VirtualAccountPurpose.id_for(:virtual_bank_account), # this is because as of now it isn't attached to an invoice or payment receivable, which will be determined later
                            customer_id: self.customer.id
                          }
            virtual_account = ::VirtualBankAccount.create(attributes)
          end
        end
      end
      # create customer account
      # Has been moved to model :after_create
      # op_customer_account_create = Invoicing::Customer::CustomerAccount::Create.(user, {customer_id: customer.id})
    else
      add_message :error, self.customer.errors.full_messages
    end
  end

  def post_process
    add_message :success, "Customer successfully created"
  end

  def success
    params[:customer] = self.customer
    Invoicing::Customer::Create::CustomerPresenter.new(user, params, messages)
  end

end
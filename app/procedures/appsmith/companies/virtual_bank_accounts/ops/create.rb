class Appsmith::Companies::VirtualBankAccounts::Ops::Create < Transactions::API
    
    step Model(VirtualBankAccount, :new)
    step :init!
    step Policy::Pundit(Appsmith::Companies::VirtualBankAccounts::Policy, :create?)
    step Contract::Build(constant: Appsmith::Companies::VirtualBankAccounts::Contract)
    step Contract::Validate()
    step :validate!
    step Contract::Persist()
    step :pre_process!
    step :process!
    step Messages::Task::SuccessMessage("Virtual bank account created")

    
    def init!(options,params:, current_app:,**)
        options["model.company"] = User.find_by(email: params[:email])&.company || params[:company]
        options["model.purpose_id"] = params[:purpose_id] || ::VirtualAccountPurpose.id_for(:virtual_bank_account)
        options["model.parent"] = params[:parent]
        options["model.virtual_bank_account_params"] = virtual_account_params(params)
        options["model.receiving_account"] = params[:receiving_account] 
        options["model.application"] = current_app || params[:application]
        options["model.customer"] = params[:customer]
    end

    def validate!(options,params:,**)
        case options["model.purpose_id"]
        when ::VirtualAccountPurpose.id_for(:cash_on_hand_return)
            unless options["model.parent"]&.is_a?(CashOnHand)
            add_message :error, 'Invalid parent type'
            return false
            end
        when ::VirtualAccountPurpose.id_for(:payment_receivable)
            unless options["model.parent"]&.is_a?(PaymentReceivable)
            add_message :error, 'Invalid parent type'
            return false
            end
        when ::VirtualAccountPurpose.id_for(:invoice)
            unless options["model.parent"]&.is_a(Invoice) &&  options["model.customer"].present?
            add_message :error, 'Invalid parent type'
            return false
            end
        else
            return true
            # in this case it's a plain old bank account creation request, so no validations?
        end
    end

    def pre_process!(options, params:,**)
        # adding the details like initiating user, purpose etc. to the Virtual Bank Account
        options["model.virtual_bank_account_params"].initiating_user = User.find_by(email: params[:email])
        options["model.virtual_bank_account_params"].parent = options["model.parent"]
        options["model.virtual_bank_account_params"].purpose_id =  options["model.purpose_id"]
        options["model.virtual_bank_account_params"].company_id = User.find_by(email: params[:email])&.company&.id
        options["model.virtual_bank_account_params"].receiving_account =  options["model.receiving_account"]
        options["model.virtual_bank_account_params"].ifsc = Constants::YesBank::YES_BANK_COLLECT_IFSC
        options["model.virtual_bank_account_params"].application = options["model.application"]
        options["model.virtual_bank_account_params"].customer_id =  options["model.customer"]&.id
        options["model.virtual_bank_account_params"].name =  options["model.virtual_bank_account_params"].name || params[:name]
    end

    def process(options,params:,**)
        op = FinlyCollect::Create.(user, collect_api_params)
        if op.success?
        bank_account_number = op.account_number
        options["model.virtual_bank_account_params"].account_number = bank_account_number
        options["model.virtual_bank_account_params"].bank_account = ::VirtualBankAccount.new(virtual_bank_account_params)
        unless options["model.virtual_bank_account_params"].bank_account.save
            FinlyCollect::Destroy.(user, account_number: bank_account_number)
            add_message :error, options["model.virtual_bank_account_params"].bank_account.errors.full_messages
            Event::EAlert::Create.(nil, title: 'Finly Collect Account created in collect server but failed to created in app',
                description: "#{options["model.virtual_bank_account_params"].bank_account.as_json}<br><br>Errors : #{options["model.virtual_bank_account_params"].bank_account.errors.full_messages}",
                subject: 'Finly Collect - Failed to create account in app')
            return
        end
        else
        add_message :error, op.messages[:error]
        end
    end

    private

    def virtual_account_params(params)
        if params[:virtual_bank_account].present?
            params.require(:virtual_bank_account).permit(:expires_by, :description, :name, :account_number,
                                                        :neft, :imps, :rtgs, :upi, :allowed_transaction_count,
                                                        :current_account, :savings_account,
                                                        :active_after, :active_on,
                                                        maximum_amount_attributes: [:value, :currency_id],
                                                        minimum_transaction_amount_attributes: [:value, :currency_id],
                                                        maximum_transaction_amount_attributes: [:value, :currency_id],
                                                        exact_transaction_amount_attributes: [:value, :currency_id])
        else
        {}
        end
    end

    def collect_api_params
        {
            account_number: virtual_account_params[:account_number],
            date_before: virtual_account_params[:expires_by],
            exact_transaction_amount: virtual_account_params[:exact_transaction_amount]
        }
    end

end
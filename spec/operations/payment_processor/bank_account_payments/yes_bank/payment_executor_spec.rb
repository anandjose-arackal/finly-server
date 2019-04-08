require 'rails_helper'

# todo - concurrent payments test
RSpec.describe 'Payment Executor Test' do

  def initialize_variables
    @company = create :company
    @feature_subscription = create :feature_subscription, subscribable: @company
    @initiating_user = create :vp_admin_user, company_id: @company.id
    @yes_bank_vendor = create :yes_bank_vendor
    @yes_bank_company_account = create :yes_bank_company_account
    @bank_account = create :bank_account, account_owner: @yes_bank_vendor, company_id: @company.id
    @yes_bank_transaction = create :yes_bank_transaction, company_id: @company.id, beneficiary_bank_account_id: @bank_account.id
    @payment_order = create :yes_bank_payment_order, initiating_user_id: @initiating_user.id,
                            payment_order_status_id: PaymentOrderStatus.id_for(:pending_approval),
                            company_id: @company.id

    @payment = create :yes_bank_payment, company_id: @company.id,
                      receiving_account_id: @bank_account.id,
                      receiving_account_type: "BankAccount",
                      reference_resource_id: @yes_bank_transaction.id,
                      payment_order_id: @payment_order.id,
                      initiating_account_id: @yes_bank_company_account.id,
                      initiating_account_type: "YesBankCompanyAccount",
                      initiating_user_id: @initiating_user.id,
                      receiving_user_id: @yes_bank_vendor.id,
                      payment_purpose_id: PaymentPurpose.id_for(:vendor_payment),
                      payment_status_id: PaymentStatus.id_for(:pending_approval)
  end

  describe '--- Payment Executor Yes Bank Success Test ---' do
    before(:all) do
      RSpec::Mocks.with_temporary_scope do
        allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).and_return(true)
        allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
        # not mocking the debit operation as that is required for us
        initialize_variables
        @payment.update(payment_status_id: PaymentStatus.id_for(:pending))
        @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
        @original_balance = @yes_bank_company_account.balance.value
        @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
      end
    end

    it 'operation should return success' do
      expect(@result.success?).to eq(true)
    end

    it 'should update the payment status as completed' do
      expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:completed))
    end

    it 'should reduce the balance of the company account' do
      new_balance = @yes_bank_company_account.reload.balance.value
      difference = @original_balance - new_balance
      expect(difference).to eq(@payment.amount_value)
    end

  end

  describe '--- Payment Executor Yes Bank Failure Tests ---' do

    describe '-- Already completed payment --' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).with(@payment).and_return(true)
          allow_any_instance_of(::AccountManager::YesBankAccount::YesBankCompanyAccountAdapter).to receive(:debit).with(@payment).and_return(true)
          allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
          initialize_variables
          @payment.update(payment_status_id: PaymentStatus.id_for(:completed))
          @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
          @original_balance = @yes_bank_company_account.balance.value
          @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
        end
      end

      it 'operation should return failure and add system messages to payment' do
        puts 'operation should return failure and add system messages to payment'
        expect(@result.success?).to eq(false)
        expect(@result.messages[:error]).to include("Payment cannot be processed in this state")
        expect(@payment.system_messages.pluck(:content)).to include("Payment cannot be processed in this state")
      end

      it 'should not reduce the company account' do
        new_balance = @yes_bank_company_account.balance.value
        difference = @original_balance - new_balance
        expect(difference).to eq(0)
      end

      it 'should change the status of the payment as failed but not for the bank transaction' do
        expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:failed))
        expect(@yes_bank_transaction.transfer_status_id).to eq(BankTransferStatus.id_for(:open))
      end

    end

    describe '-- Should not process for an account that is on hold --' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).with(@payment).and_return(true)
          allow_any_instance_of(::AccountManager::YesBankAccount::YesBankCompanyAccountAdapter).to receive(:debit).with(@payment).and_return(true)
          allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
          initialize_variables
          @payment.update(payment_status_id: PaymentStatus.id_for(:pending))
          @payment.receiving_account.update(on_hold: true)
          @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
          @original_balance = @yes_bank_company_account.balance.value
          @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
        end
      end

      it 'operation should return failure and add relevant system messages to payment' do
        puts 'operation should return failure and add system messages to payment'
        expect(@result.success?).to eq(false)
        expect(@result.messages[:error]).to include("Transfers to this account have been temporarily put on hold")
        expect(@payment.system_messages.pluck(:content)).to include("Transfers to this account have been temporarily put on hold")
      end

      it 'should not reduce the company account' do
        new_balance = @yes_bank_company_account.balance.value
        difference = @original_balance - new_balance
        expect(difference).to eq(0)
      end

      it 'should change the status of the payment as failed but not for the bank transaction' do
        expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:failed))
        expect(@yes_bank_transaction.transfer_status_id).to eq(BankTransferStatus.id_for(:open))
      end

      it 'should update the payment as on hold' do
        expect(@payment.on_hold).to eq(true)
      end

    end

    describe '-- Should not process for an account that is disabled --' do
      before(:all) do
        RSpec::Mocks.with_temporary_scope do
          allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).with(@payment).and_return(true)
          allow_any_instance_of(::AccountManager::YesBankAccount::YesBankCompanyAccountAdapter).to receive(:debit).with(@payment).and_return(true)
          allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
          initialize_variables
          @payment.update(payment_status_id: PaymentStatus.id_for(:pending))
          @payment.receiving_account.update(disabled: true)
          @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
          @original_balance = @yes_bank_company_account.balance.value
          @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
        end
      end

      it 'operation should return failure and add relevant system messages to payment' do
        puts 'operation should return failure and add system messages to payment'
        expect(@result.success?).to eq(false)
        expect(@result.messages[:error]).to include("You cannot make transfers to this bank account as it has been blacklisted")
        expect(@payment.system_messages.pluck(:content)).to include("You cannot make transfers to this bank account as it has been blacklisted")
      end

      it 'should not reduce the company account' do
        new_balance = @yes_bank_company_account.balance.value
        difference = @original_balance - new_balance
        expect(difference).to eq(0)
      end

      it 'should change the status of the payment as failed but not for the bank transaction' do
        expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:failed))
        expect(@yes_bank_transaction.transfer_status_id).to eq(BankTransferStatus.id_for(:open))
      end

      it 'should update the payment as disabled' do
        expect(@payment.disabled).to eq(true)
      end

    end

  end

end
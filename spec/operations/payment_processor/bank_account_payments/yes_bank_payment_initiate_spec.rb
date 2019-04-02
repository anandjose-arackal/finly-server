require 'rails_helper'

RSpec.describe 'Payment Initiation via YesBank' do

  before :all do
    # mocking the returns of all the related classes inside the PaymentExecutor
    RSpec::Mocks.with_temporary_scope do
      allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).with(@payment).and_return(true)
      allow_any_instance_of(::AccountManager::YesBankAccount::YesBankCompanyAccountAdapter).to receive(:debit).with(@payment).and_return(true)
    end
  end

  before :each do
    @company = create :company
    @yes_bank_vendor = create :yes_bank_vendor
    @bank_account = create :bank_account, account_owner: @yes_bank_vendor, company_id: @company.id
    @yes_bank_transaction = create :yes_bank_transaction
    @payment = create :yes_bank_payment, company_id: @company.id, receiving_account_id: @bank_account.id, reference_resource_id: @yes_bank_transaction.id
    @initiating_account = @payment.initiating_account
    @original_balance = @initiating_account.balance.value
  end

  describe '--- Payment Executor Yes Bank Success Test ---' do
    before(:each) do
      # set payment status to pending
      @payment.update(payment_status_id: PaymentStatus.id_for(:pending))
      @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
      @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
    end

    it 'operation should return success' do
      expect(@result.success?).to eq(true)
    end

    it 'should update the payment status as completed' do
      expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:completed))
    end

    it 'should update the bank transaction status' do
      expect(@yes_bank_transaction.transfer_status_id).to eq(BankTransferStatus.id_for(:completed))
    end

    it 'should reduce the balance of the company account' do
      new_balance = @initiating_account.balance.value
      difference = @original_balance - new_balance
      expect(difference).to eq(@payment.amount_value)
    end

  end

  describe '--- Payment Executor Yes Bank Failure Tests ---' do
    before(:each) do

    end

    describe '-- Already completed payment --' do
      before(:all) do
        @payment.update(payment_status_id: PaymentStatus.id_for(:completed))
        @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
        @result = AccountManager::Payments::PaymentExecutor.(@payment)
      end

      it 'operation should return failure and add system messages to payment' do
        expect(@result.success?).to eq(false)
        expect(@result.messages[:error]).to include("Payment cannot be processed in this state")
        expect(@payment.system_messages.pluck(:content)).to include("Payment cannot be processed in this state")
      end

      it 'should not reduce the company account' do
        new_balance = @initiating_account.balance.value
        difference = @original_balance - new_balance
        expect(difference).to eq(0)
      end

      it 'should not change the status of the payment or the bank transaction' do
        expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:completed))
      end

    end

  end

end
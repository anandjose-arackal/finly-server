require 'rails_helper'

RSpec.describe 'Payment Initiation via YesBank' do

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

    @original_balance = @yes_bank_company_account.balance.value
  end

  before :each do
    # mocking the returns of all the related classes inside the PaymentExecutor
    RSpec::Mocks.with_temporary_scope do
      allow_any_instance_of(::AccountManager::BankAccount::BankAccountYesBankAdapter).to receive(:credit).with(@payment).and_return(true)
      allow_any_instance_of(::AccountManager::YesBankAccount::YesBankCompanyAccountAdapter).to receive(:debit).with(@payment).and_return(true)
      allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
    end
  end

  before :each do
    # initialize_variables
    RSpec::Mocks.with_temporary_scope do
      # allow_any_instance_of(Company).to receive(:yes_bank_account_enabled?).and_return(true)
    end
  end

  # describe '--- Payment Executor Yes Bank Success Test ---' do
  #   before(:each) do
  #     # set payment status to pending
  #     @payment.update(payment_status_id: PaymentStatus.id_for(:pending))
  #     @yes_bank_transaction.update(transfer_status_id: BankTransferStatus.id_for(:open))
  #     @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
  #   end
  #
  #   it 'operation should return success' do
  #     expect(@result.success?).to eq(true)
  #   end
  #
  #   it 'should update the payment status as completed' do
  #     expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:completed))
  #   end
  #
  #   it 'should reduce the balance of the company account' do
  #     new_balance = @yes_bank_company_account.reload.balance.value
  #     difference = @original_balance - new_balance
  #     expect(difference).to eq(@payment.amount_value)
  #   end
  #
  # end

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
          @result = ::AccountManager::Payments::PaymentExecutor.(@payment)
        end
      end

      it 'should check for mocking' do
        expect(@company.yes_bank_account_enabled?).to eq(true)
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

      it 'should not change the status of the payment or the bank transaction' do
        expect(@payment.payment_status_id).to eq(PaymentStatus.id_for(:completed))
        expect(@yes_bank_transaction.transfer_status_id).to eq(BankTransferStatus.id_for(:open))
      end

    end

  end

end
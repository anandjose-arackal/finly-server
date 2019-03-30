require 'rails_helper'

RSpec.describe 'Payment Initiation via YesBank' do

  before :all do
    @company = create :company
    @bpr = create :bank_payment_request
    @payment = create :company
    @yes_bank_transaction = create :yes_bank_transaction
  end

  describe 'Payment Initiation From API' do
    before(:all) do

    end
  end

  describe 'Payment Initiation from Dashboard' do

  end


end
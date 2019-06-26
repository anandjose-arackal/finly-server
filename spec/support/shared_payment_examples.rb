RSpec.shared_examples "Payment should not be initiated" do
  it "payment status should be failed" do
    @payment.failed?
    @payment.bank_transaction.failed?
    @payment.bank_transaction.bank_reference_number.blank?
  end
end
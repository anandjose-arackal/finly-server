class BankTransferAgreement < ActiveRecord::Migration
  def change
    AgreementType.seed_data
  end
end

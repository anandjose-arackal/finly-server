class BankTransferAgreement < ActiveRecord::Migration[4.2]
  def change
    AgreementType.seed_data
  end
end

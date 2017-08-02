class FundsLoadsRequestType < ActiveRecord::Migration
  def up
    create_table :company_funds_load_request_types do |t|
      t.string :name
    end

    CompanyFundsLoadRequestType.seed_data
    add_reference :company_funds_load_requests, :bank_type, references: :company_funds_load_request_type, index: true

    CompanyFundsLoadRequest.all.each do |r|
      r.update(bank_type_id: CompanyFundsLoadRequestType.id_for(:itzcash))
    end
  end

  def down
    drop_table :company_funds_load_request_types

    remove_foreign_key :company_funds_load_requests, column: 'bank_type_id'
    remove_column :company_funds_load_requests, :bank_type_id, :integer
  end
end

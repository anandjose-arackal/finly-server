class CreateOtpRequestTypes < ActiveRecord::Migration
  def change
    create_table :otp_request_types do |t|
      t.string :name

      t.timestamps null: false
    end

    add_column :users, :otp_request_type_id, :integer, references: "OtpRequestType", foreign_key: true, index: true
  end
end

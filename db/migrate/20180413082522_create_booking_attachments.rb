class CreateBookingAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :booking_attachments do |t|
      t.attachment :attachment
      t.references :booking, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.references :company, index: true, foreign_key: true
      t.text :description

      t.timestamps null: false
    end
  end
end

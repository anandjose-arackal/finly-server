class UpdateEmailSubjectToText < ActiveRecord::Migration[4.2]
  def change
    change_column :receipt_emails, :subject, :text
  end
end

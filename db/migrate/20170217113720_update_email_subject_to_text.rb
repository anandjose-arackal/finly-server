class UpdateEmailSubjectToText < ActiveRecord::Migration
  def change
    change_column :receipt_emails, :subject, :text
  end
end

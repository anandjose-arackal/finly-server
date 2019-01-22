class CreateReportCommentActions < ActiveRecord::Migration[4.2]
  def change
    create_table :report_comment_actions do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end

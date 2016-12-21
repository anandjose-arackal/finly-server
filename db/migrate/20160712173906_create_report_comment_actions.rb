class CreateReportCommentActions < ActiveRecord::Migration
  def change
    create_table :report_comment_actions do |t|
      t.string :name, null: false

      t.timestamps null: false
    end
  end
end

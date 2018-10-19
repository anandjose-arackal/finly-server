class AddUserToInwardDocument < ActiveRecord::Migration
  def change
    add_reference :inward_documents, :user, index: true, foreign_key: true
  end
end

class CreateResourceRequests < ActiveRecord::Migration[4.2]
  def change
    create_table :resource_requests do |t|
      t.string :name
      t.string :email
      t.string :mobile_number
    end
  end
end

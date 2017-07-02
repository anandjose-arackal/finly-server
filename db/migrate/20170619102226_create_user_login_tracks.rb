class CreateUserLoginTracks < ActiveRecord::Migration
  def change
    create_table :user_login_tracks do |t|
      t.references :user, index: true, foreign_key: true, null: false
      t.string :ip_address
      t.string :referrer
      t.string :application

      t.timestamps null: false
    end
  end
end

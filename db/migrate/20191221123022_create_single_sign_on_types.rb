class CreateSingleSignOnTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :single_sign_on_types do |t|
      t.string :name

      t.timestamps
    end

    SingleSignOnType.seed_data
  end
end

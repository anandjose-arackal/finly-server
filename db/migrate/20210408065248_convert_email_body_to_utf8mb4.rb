class ConvertEmailBodyToUtf8mb4 < ActiveRecord::Migration[6.0]
  def change
    ActiveRecord::Base.connection.execute("ALTER TABLE email_bodies MODIFY body LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")

    ActiveRecord::Base.connection.execute('TRUNCATE TABLE ml_model_pmmls')
    ActiveRecord::Base.connection.execute("ALTER TABLE ml_model_pmmls MODIFY body LONGTEXT CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;")
  end
end

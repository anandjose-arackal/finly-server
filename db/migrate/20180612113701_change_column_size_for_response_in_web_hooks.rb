class ChangeColumnSizeForResponseInWebHooks < ActiveRecord::Migration
  def change
    change_column :web_hook_tracks, :response_body, :text, limit: 16.megabytes - 1
  end
end

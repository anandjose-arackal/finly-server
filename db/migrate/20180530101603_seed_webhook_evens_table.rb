class SeedWebhookEvensTable < ActiveRecord::Migration[4.2]
  def change
    WebHookEvent.seed_data
  end
end

class SeedWebhookEvensTable < ActiveRecord::Migration
  def change
    WebHookEvent.seed_data
  end
end

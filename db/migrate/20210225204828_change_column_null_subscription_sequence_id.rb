class ChangeColumnNullSubscriptionSequenceId < ActiveRecord::Migration[6.0]
  def change
    change_column_null :bbps_biller_subscriptions, :sequence_id, true
  end
end

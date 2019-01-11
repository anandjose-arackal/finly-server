class SeedNotifierTypesForBankPaymentRequest < ActiveRecord::Migration[4.2]
  def change
    NotifierType::ACTIONS.each do |item|
      unless NotifierType.find_by(name: item[:key].to_s)
        NotifierType.create id: (NotifierType::ACTIONS.find_index(item) + 1), name: item[:key].to_s,
                            has_push_notification: item[:has_push_notification], has_mailer: item[:has_mailer],
                            configurable_push_notification: item[:configurable_push_notification],
                            configurable_mailer: item[:configurable_mailer]
      end
    end
    NotificationType.seed_data
  end
end

namespace :patch do

  desc '14-02-2017: Fixing user card restriction association'
  task association_fix: :environment do
    User.all.each do |user|
      res = CardRestriction.find_by(card_id: user.id)
      if user.cards.present?
        card = user.cards.first
        res.update(card_id: card.id)
      else
        res.destroy
      end
    end
  end

  desc '15-02-2017: Allow push notifications for all users for money requests'
  task push_notification_configuration_update: :environment do
    notifiers = NotifierType.where("name LIKE 'money_request%'")
    notifiers.update_all(configurable_push_notification: true, has_push_notification: true)
  end

  desc '15-02-2017: Rename advance request to money request in database'
  task rename_advance_request_to_money_request: :environment do
    NotificationType.find(7).update_attribute(:name, "money_request")
  end

  desc '20-02-2017: Adding a dB entry for card_transaction in NotifierType'
  task add_card_transaction_notifier_type: :environment do
    item = NotifierType::ACTIONS.last
    NotifierType.create id: (NotifierType::ACTIONS.find_index(item) + 1), name: item[:key].to_s,
                        has_push_notification: item[:has_push_notification], has_mailer: item[:has_mailer],
                        configurable_push_notification: item[:configurable_push_notification],
                        configurable_mailer: item[:configurable_mailer]
  end

end

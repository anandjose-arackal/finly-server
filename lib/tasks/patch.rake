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

end

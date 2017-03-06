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

  desc "22-02-2017: Renaming the 'advance' and 'debt clearance' payment types to 'add cash on hand' and 'deduct cash on hand'"
  task rename_payment_types: :environment do
    PaymentType.first.update(name: "add_cash_on_hand")
    PaymentType.second.update(name: "deduct_cash_on_hand")
  end

  desc "27-02-2017: Destroying all the junk transactions that were created by ItzCash's Message Queue Fiasco"
  task destroy_junk_transactions: :environment do
    start_time = DateTime.parse('25-02-2017 00:00 +05:30')
    end_time = DateTime.parse('25-02-2017 05:00 +05:30')
    company = Company.find_by(name: "Jouska")
    company.users.each do |user|
      user.card_transactions.where('created_at >= ? && created_at <= ?', start_time, end_time).each do |trans|
        trans.destroy
      end
    end
  end

  desc '02-03-2017: Manually updated company d_code from company.d_code to company.itz_cash_property.d_code'
  task rename_payment_types: :environment do
    # manually updated company d_code from company.d_code to company.itz_cash_property.d_code
  end

  desc '07-03-2017: Add field values for custom fields'
  task add_field_types: :environment do
    if FieldParentType.count == 0
      FieldParentType::TYPES.each do |key, value|
        FieldParentType.create id: value, name: key
      end
    end

    if FieldType.count == 0
      FieldType::TYPES.each do |key, value|
        FieldType.create id: value, name: key
      end
    end
  end

end

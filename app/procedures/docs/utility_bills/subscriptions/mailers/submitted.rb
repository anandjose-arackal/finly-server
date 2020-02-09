class Docs::UtilityBills::Subscriptions::Mailers::Submitted < Notifier::Mailer

  # consumes_event! '', consumer_key:, name:, sync: false, options: {}
  # consumes_event! 'bbps_biller_subscription.submit'

  consumes_event! 'bbps_biller_subscription.submit', consumer_key: '::Notifer::Router', name: "Test Mailer"
    # def self.event(event_name)
    #   # consumes_event! 'bbps_bill.submit'
    #   # consumes_event! 'bbps_biller_subscription.submit', consumer_key: "mailer", name: "Test Mailer"
    #   consumes_event! 'bbps_biller_subscription.submit', consumer_key: Notifer::Router, name: "Test Mailer"
    # end
  # consumes_event! 'bbps_biller_subscriptions.submit', consumer_key: "X", name: "Y", sync: true
end
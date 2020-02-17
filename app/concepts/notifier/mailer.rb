# Mandatory
# to, subject, :body_header, :template, :

class Notifier::Mailer < Notifier::API
  # require 'bunny'

  assign :from, "noreply@finly.io"
  assign :subject, "Finly Notification"
  assign :body_header, "New Notification from Finly"

  def permissions(ctx, options)
    true
  end

  # def self.bunny_queue(queue)
  #   connection = Bunny.new(automatically_recover: false)
  #   connection.start
  #
  #   channel = connection.create_channel
  #   queue = channel.queue(queue)
  #
  #   begin
  #     puts ' [*] Waiting for messages. To exit press CTRL+C'
  #     # block: true is only used to keep the main thread
  #     # alive. Please avoid using it in real world applications.
  #     queue.subscribe(block: true) do |_delivery_info, _properties, body|
  #       puts " [x] Received #{body}"
  #     end
  #   rescue Interrupt => _
  #     connection.close
  #
  #     exit(0)
  #   end
  # end

  def prepare(options, params:, current_user:, **)
    super
  end

  def validate(ctx, options)
    true
  end

  def dispatch(options, payload:, **)
    ap payload
    NotifierMailer.delay.send_mail(payload.to_json.to_s)
    true
  end

end
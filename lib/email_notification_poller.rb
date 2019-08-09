require "#{Rails.root}/lib/security"
class EmailNotificationPoller

  def self.run

    unless File.exists?('config/aws_config.yml')
      raise 'aws_config.yml not found'
    end

    ####################### Initializing the client and other details for pulling messages from AWS Queue #########
    aws_config = Rails.application.config_for(:aws_config)
    region_name = aws_config["email_tracker_aws_region_name"]
    access_key_id = aws_config["aws_access_key_id"]
    secret_access_key = aws_config["aws_secret_access_key"]

    sqs_client = Aws::SQS::Client.new(region: region_name, access_key_id: access_key_id, secret_access_key: secret_access_key)

    queue_url_base = aws_config["email_tracker_queue_url"]
    queue_name = aws_config["email_tracker_queue_name"]

    queue_url = queue_url_base + queue_name

    # initializing the log file that will hold the errors if necessary
    error_logger = Logger.new("#{Rails.root}/log/email_notification_poller_errors.log")
    poller = Aws::SQS::QueuePoller.new(queue_url, {client: sqs_client})
    file_logger = LogStashLogger.new(type: :file, path: 'log/logstash_email_notification_poller.log', sync: true)

    ######################## AWS Code to extract the messages from the queue ###################

    poller.poll do |notification|
      puts notification.body

      body = notification.body || {}
      data = JSON.parse(body)&.with_indifferent_access rescue nil
      message = JSON.parse(data['Message'])&.with_indifferent_access rescue nil

      log_params = {
          request_id: Security.generate_hmac_hex(self.object_id.to_s, DateTime.now.to_s),
          payload: message
      }

      if message.nil?
        log_params[:operation_success] = false
        log_params[:failure_reason] = "Unable to parse body"
        file_logger.info(log_params)
      else
        event = message['eventType']
        event_id = data['MessageId']
        message_id_hash = message['mail']['headers'].find {|m| m[:name] == 'Message-ID'}
        # Strip < and > in Message ID
        message_id = message_id_hash&.dig(:value)[/#{"<"}(.*?)#{">"}/m, 1] || message_id_hash&.dig(:value) #data&.dig('mail', 'messageId')
        event_key = event&.parameterize&.underscore
        timestamp = nil
        timestamp = Date.parse message&.dig(event_key, 'timestamp') if message&.dig(event_key, 'timestamp')
        ip_addr = message&.dig(event_key, 'ipAddress')
        user_agent = message&.dig(event_key, 'userAgent')
        link = message&.dig(event_key, 'link')
        link_tags = message&.dig(event_key, 'linkTags')

        begin
          if message_id.nil?
            log_params[:operation_success] = false
            log_params[:failure_reason] = 'Message ID is nil'
            file_logger.warn(log_params)
          elsif EmailEvent.find_by(event_id: event_id).present?
            # Do nothing if the event is duplicate event
            log_params[:operation_success] = false
            log_params[:failure_reason] = 'Duplicate Event'
            file_logger.warn(log_params)
          else
            email = Email.find_by(message_id: message_id)
            if email.nil?
              log_params[:operation_success] = false
              log_params[:failure_reason] = "Email with message ID #{message_id} not found"
              file_logger.info(log_params)
            else
              event_params = {
                  event_id: event_id,
                  event: event,
                  timestamp: timestamp,
                  ip_addr: ip_addr,
                  user_agent: user_agent,
                  link: link,
                  link_tags: link_tags,
                  payload: message
              }
              email_event = email.events.build(event_params)
              if email_event.save
                log_params[:operation_success] = true
                file_logger.info(log_params)
              else
                log_params[:operation_success] = false
                log_params[:failure_reason] = email_event.errors.full_messages
                file_logger.info(log_params)
              end
            end
          end
        rescue => error
          error_logger.error("Following history entry : #{notification.body} couldn't be created because of the following errors: #{error.message}")

          stack_trace = error.message
          error.backtrace.each do |line|
            stack_trace += "\n#{line}"
          end
          log_params[:operation_success] = false
          log_params[:failure_reason] = error.message
          log_params[:stacktrace] = stack_trace
          file_logger.warn(log_params)
        end
      end
    end
  end

end
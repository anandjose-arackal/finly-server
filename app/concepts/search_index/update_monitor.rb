class SearchIndex::UpdateMonitor

  REDIS_QUEUE = 'meilisearch_update_queue'

  def self.with_tracking(index_name, &block)
    response = block.call
    update_id = response['updateId']
    if update_id.present? and Rails.configuration.meilisearch_monitor
      Rails.configuration.redis.lpush(REDIS_QUEUE, {index: index_name, update_id: update_id}.to_json)
    end
    response
  end

  def self.run
    unless Rails.configuration.meilisearch_monitor
      puts 'Not listening as meilisearch_monitor is set to false'
      return
    end

    logger = LogStashLogger.new(type: :file, path: 'log/meilisearch_error.log', sync: true)
    puts 'Listening...'
    begin
      loop do
        while (update_data_json = Rails.configuration.redis.lpop(REDIS_QUEUE)).present?
          puts "New Event: #{update_data_json}"
          update_data = JSON.parse(update_data_json)
          index_name = update_data['index']
          update_id = update_data['update_id']
          index = Rails.configuration.meilisearch.index(index_name)
          begin
            update_status = index.get_update_status(update_id)
            if update_status['status'] == 'enqueued'
              Rails.configuration.redis.lpush(REDIS_QUEUE, update_data_json)
            else
              logger.info({message_type: 'job'}.merge(update_status))
            end
            sleep 0.5.seconds
          rescue MeiliSearch::ApiError => e
            logger.error({message_type: 'error', message: e.message})
          end
        end
        sleep 10.seconds
      end
    rescue SystemExit, Interrupt
      puts 'Scheduling Exit'
      puts 'Bye'
    rescue Exception => e
      logger.error({message_type: 'crash', message: ([e.message] + e.backtrace).join("\n")})
    end
  end

end
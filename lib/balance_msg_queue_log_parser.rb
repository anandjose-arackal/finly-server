class BalanceMsgQueueLogParser

  def self.parse(options={})
    path = (options&.dig(:path) || "#{Rails.root}/log/balance_msg_queue_poller.log")
    return nil unless File.exists?(path)
    map = {}
    File.open(path, "r").each_line do |line|
      # name: "Angela"    job: "Writer"    ...
      data = line.split(',')
      next unless data.size >= 4
      card_serial_id = data[1]
      card = Card.find_by_proxy(card_serial_id)
      balance = data[2]
      puts data[3]
      datetime = Date.parse data[3] rescue nil
      next if datetime.blank?
      datetime_s = DateUtils.date_formatted datetime
      map[card_serial_id] = {} if map[card_serial_id].nil?
      map[card_serial_id][datetime_s] = balance
    end
    map
  end

end
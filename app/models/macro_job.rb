# == Schema Information
#
# Table name: macro_jobs
#
#  id              :bigint           not null, primary key
#  macro_id        :integer          not null
#  started_at      :datetime
#  ended_at        :datetime
#  execution_time  :integer
#  request_options :text(65535)
#  status_id       :integer          not null
#  deleted_at      :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class MacroJob < FinlyMacrosRecord
  belongs_to :macro
  belongs_to :status, class_name: 'MacroJobStatus'

  has_many :logs, class_name: 'MacroJobLog'

  serialize :request_options, JSON

  def std_pretty_print
    puts "#{"=" * 10} #{macro.name} #{"=" * 10}"
    puts "Macro\t\t\t:\t#{macro.name}"
    puts "Description\t\t:\t#{macro.name}"
    puts "Run Time\t\t:\t#{execution_time} seconds"
    logs.each do |log|
      puts "==> [#{log.created_at} - #{log.log_type}\t]\t#{log.message.as_json}"
    end
  end

  def as_json(options={})
    {
        id: id,
        started_at: started_at&.strftime("%d-%B-%Y %H:%M:%S"),
        ended_at: ended_at&.strftime("%d-%B-%Y %H:%M:%S"),
        execution_time: execution_time,
        status: status.as_json(options),
        logs: logs.as_json(options)
    }
  end

end

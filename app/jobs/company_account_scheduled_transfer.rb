class CompanyAccountScheduledTransfer < ApplicationJob

  def perform
    configs = CompanyFundsAutoTransferConfig.enabled

    for config in configs
      if transfer_today?(config)
        params = {
          company: config.company
        }
        result = Event::ECompanyFundsAutoTransfer::Transfer.(nil, params)
      end
    end

  end

  private

  def transfer_today?(config)
    day = config.frequency_day
    today = Date.today
    case conifg.frequency_name
      when 'day'
        return true
      when 'week'
        if today.wday == day.to_i
          return true
        end
      when 'month'
        if today.day == day.to_i
          return true
        end

        if today.end_of_month.day <= day.to_i
          return true
        end

      else
        false
    end
  end
end

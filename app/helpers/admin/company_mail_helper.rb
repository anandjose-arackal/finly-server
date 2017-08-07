module Admin::CompanyMailHelper

  def random_ip_address(company)
    case company.id
      when 29
        return "1.23.161.61"
      else
        ips = Constants::JUNK_IP_ADDRESSES
        ips[random_integer(0, 19)]
    end
  end

  def random(low, high)
    rand * (high - low) + low
  end

  def random_integer(low, high)
    random(low, high).to_i
  end

  def agreement_acceptance_timestamp(company)
    case company.id
      when 22
        return DateTime.parse("2017-07-26 13:01:37 +0530").to_time
      when 25
        return DateTime.parse("2017-07-26 13:29:38 +0530").to_time
      when 5
        return DateTime.parse("2017-07-26 13:52:06 +0530").to_time
      when 29
        return DateTime.parse("2017-08-02 22:28:10 +0530").to_time
      else
        return random_timestamp
    end
  end

  def random_timestamp
    start_time = 10.days.ago.to_time
    end_time = Time.now
    time = nil
    loop do
      time = rand(start_time..end_time)
      if time.hour >= 8 && time.hour <= 22
        break
      end
    end
    time
  end

end
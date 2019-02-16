module IPHelper

  def random_ip
    IPAddr.new(rand(2 ** 32), Socket::AF_INET).to_s
  end

end
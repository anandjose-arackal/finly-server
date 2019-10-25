class Documents::Master

  def self.list
    %w(Invoice BbpsBillerSubscription)
  end

  def self.for(model_name)
    if list.include?(model_name)
      Object.const_get(model_name)
    end
  end

end
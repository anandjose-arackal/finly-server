class Master
  include Observer::Master

  observers_path "#{Rails.root}/app/gatekeeper/observers"

end
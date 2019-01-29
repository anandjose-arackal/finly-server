class Gatekeeper::Masters::BaseMaster
  include Observer::Observable

  observer_keys :event

end
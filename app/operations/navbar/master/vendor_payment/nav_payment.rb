class Navbar::Master::VendorPayment::NavPayment < Navbar::Master::Base

  register_app :vp

  def self.accept?
    false
  end

end
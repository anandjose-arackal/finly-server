class BranchLocation < ActiveRecord::Base
  belongs_to :company
  belongs_to :state


  def address
    address = ""
    if self.address_1.present?
      address += (self.address_1 + ",\n")
    end
    if self.address_2.present?
      address += (self.address_2 + ",\n")
    end
    if self.city.present?
      address += (self.city + ", ")
    end
    if self.state.present?
      address += (self.state.name + ",\n")
    end
    if self.pin.present?
      address += (self.pin)
    end
  end
end

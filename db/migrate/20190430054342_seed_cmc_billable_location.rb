class SeedCmcBillableLocation < ActiveRecord::Migration[5.2]
  def change
    BranchLocation.unscoped.all.update_all(billable_location: true, shippable_location: true)
    company = Company.find(140) rescue false
    if company.present?
	    company.locations.update_all(billable_location: false)
	    location_params ={name: "Sobek Auto India Private Limited", address_1: "4TH FLOOR, TOWER 3A, CORPORATE PARK, DLF CITY,
	PHASE -III, GURGAON", pin: '122002', state_id:15, billable_location:true, shippable_location: false}
	    company.locations.create(location_params)
	end
  end
end

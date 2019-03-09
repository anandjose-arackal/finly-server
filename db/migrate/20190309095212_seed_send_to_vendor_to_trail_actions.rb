class SeedSendToVendorToTrailActions < ActiveRecord::Migration[5.2]
  def change
  	TrailAction.where(name:'sent_to_vendor').update(name: 'send_to_vendor')
  end
end

task :add_company_id_to_bpr => :environment do

  BankPaymentRequest.all.find_each do |bpr|
    bpr.company_id = bpr.owner.company_id
    bpr.save
  end
end
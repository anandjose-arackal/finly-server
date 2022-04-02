namespace :gst_types do

  # rake gst_types:insert_vat
  task :insert_vat => :environment do
    vat = GstType.create({name: 'vat'})
    if vat
      p "vat gst_type added"
    else
      p "migration failed"
    end
  end
end
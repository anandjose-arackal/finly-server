class Admin::Implementations::Master::TdsSlabs::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.import'
  headers ({
      :id => "ID",
      :name => "Name",
      :tds => "TDS Rate",
      :destroy => "Destrou"
  })

  def create_record(data)
    tds_slab = self.company.tds_slabs.new data.except(:id,:destroy)
    unless tds_slab.save
      return result false, tds_slab.errors.full_messages
    end
    result true, 'Created Successfully'
  end


  def destroy_records(data)
    tds_slab = self.company.tds_slabs.find_by id: data[:id]
    unless tds_slab
      return result false, "Cost Center not found"
    end
    unless tds_slab.destroy
      return result false, tds_slab.errors.full_messages
    end
    result true, "Destroyed Successfully"
  end

end

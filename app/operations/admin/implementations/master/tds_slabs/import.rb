class Admin::Implementations::Master::TdsSlabs::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.import'
  headers [
              :id,
              :name,
              :tds
          ]
  def create_record(data)
    tds_slab = self.company.tds_slabs.new data.except(:id,:destroy)
    unless tds_slab.save
      return result false, tds_slab.errors.full_messages
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    tds_slab = self.company.tds_slabs.find_by id: data[:id]
    unless tds_slab
      return result false, "TDS Slab not found"
    end

    unless tds_slab.update(data.except(:destroy,:tds))
      return result false, tds_slab.errors.full_messages
    end
    return result true, 'Updated Successfully'
  end

end

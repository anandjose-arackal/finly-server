class Admin::Implementations::Master::TdsSlabs::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'tds_slabs.import'
  headers ({
      :id => "ID",
      :name => "Name",
      :tds => "TDS Rate",
      :destroy => "Destroy"
  })

  def create_record(data)
    messages = validate_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    tds_slab = self.company.tds_slabs.new data.except(:id,:destroy)
    unless tds_slab.save
      return result false, tds_slab.errors.full_messages
    end
    result true, 'Created Successfully'
  end


  def destroy_records(data)
    messages = validate_params(data)
    unless messages.blank?
      return result false, messages.join(', ')
    end
    tds_slab = self.company.tds_slabs.find_by id: data[:id]
    unless tds_slab
      return result false, "TDS not found"
    end
    unless tds_slab.destroy
      return result false, tds_slab.errors.full_messages
    end
    result true, "Destroyed Successfully"
  end

  def validate_params(data)
    messages = []
    if data[:name].blank?
      messages << "TDS Name cant blank"
    end

    if data[:tds].blank?
      messages << "TDS Rate cant blank"
    end

    if data[:tds].present? &&  data[:tds]&.to_i < 0
      messages << "TDS Cant be Negative"
    end

    if data[:tds].is_a?(String)
      messages << "TDS value will be numeric"
    end
    messages
  end
end

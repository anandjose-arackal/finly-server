class Admin::Implementations::Master::CostCenters::Import < Admin::Implementations::Processor::Import

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'cost_centers.import'
  headers [
              :id,
              :name,
              :cost_center_code,
              :expense_management,
              :vendor_payment,
              :destroy
          ]

  def create_record(data)
    applications = []
    applications << 'em' if data[:expense_management]&.upcase == 'Y'
    applications << 'vp' if data[:vendor_payment]&.upcase == 'Y'
    if applications.blank?
      return result false, "Enable EM or VP"
    end
    applications.each do |application|
      data[:cost_center_code] = nil if data[:cost_center_code].blank?
      cost_center = self.company.cost_centers.new data.except(:id,:destroy,:expense_management, :vendor_payment)
      cost_center.application = application
        unless cost_center.save
          return result false, cost_center.errors.full_messages
        end
    end
    result true, 'Created Successfully'
  end

  def update_record(data)
    cost_center = self.company.cost_centers.find_by id: data[:id]
    unless cost_center
      return result false, "Cost Center not found"
    end
    data[:application] = data[:expense_management]&.upcase == 'Y' ? 'em' : 'vp'
    unless cost_center.update(data.except(:destroy,:expense_management, :vendor_payment))
      return result false, cost_center.errors.full_messages
    end
    result true, 'Updated Successfully'
  end

  def destroy_records(data)
   cost_center = self.company.cost_centers.find_by id: data[:id]
   unless cost_center
    return result false, "Cost Center not found"
   end
   unless cost_center.destroy
     return result false, cost_center.errors.full_messages
   end
   result true, "Destroyed Successfully"
  end
end

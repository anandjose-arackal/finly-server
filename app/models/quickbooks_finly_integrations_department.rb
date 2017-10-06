class QuickbooksFinlyIntegrationsDepartment
  include QuickbooksFinlyIntegratable

  attr_accessor :name

  def save
    if self.valid?
      # add logic to save the new department into the DB
      company = Company.find_by(id: self.company_id)
      qb_department = company.quickbooks_departments.build(
                                            name: self.name,
                                            quickbooks_id: self.quickbooks_id,
                                            active: self.active,
                                            additional_information: self.quickbooks_additional_information
                                           )
      qb_department.save
    end
  end
end
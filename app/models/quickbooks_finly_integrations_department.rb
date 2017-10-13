class QuickbooksFinlyIntegrationsDepartment
  include QuickbooksFinlyIntegratable

  attr_accessor :name

  def save
    if self.valid?
      # add logic to save the new department into the DB

      company = Company.find_by(id: self.company_id)
      qb_department = QuickbooksDepartment.find_by(quickbooks_id: self.quickbooks_id, company_id: company.id) || QuickbooksDepartment.find_by(name: self.name, company_id: company.id)
      if qb_department.blank?
        qb_department = company.quickbooks_departments.build(
                                              name: self.name,
                                              quickbooks_id: self.quickbooks_id,
                                              active: self.active,
                                              additional_information: self.quickbooks_additional_information
                                             )
        qb_department.save
      else
        qb_department.update(
            name: self.name,
            quickbooks_id: self.quickbooks_id,
            active: self.active,
            additional_information: self.quickbooks_additional_information
        )
      end
    end
  end
end
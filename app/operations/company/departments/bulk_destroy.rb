class Company::Departments::BulkDestroy < Company::Departments::Base
  attr_accessor :departments

  def init
    department_ids = params[:ids] || params[:department_ids]
    self.departments = user.company.departments.where id: department_ids
  end

  def authorized_user_types
    [:company_admin, :vendor_payments_admin]
  end

  def validate
    if self.departments.blank?
      add_message :error, "No departments found."
      return
    end
  end


  def process
    # if self.department.delete_all
    if self.departments.destroy_all
      add_message :success, 'Successfully Removed Multiple Departments'
    else
      add_message :error, "Couldn't remove multiple departments"
    end
  end

end

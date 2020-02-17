module Admin::Implementations::Processor::Finders

  def find(required: false, error_key: nil, klass: nil, failure_message: nil, &block)
    value = block.call
    if value or not required
      return Success(value)
    end

    failure_message ||= "#{klass} not found" if klass
    failure_message ||= "#{error_key} not found" if error_key
    failure_message ||= "Error: Field is found"
    Failure(failure_message)
  end

  def find_user(identifier, required: false)
    find error_key: "User #{identifier}", required: required do
      company.users.find_by(email: identifier)
    end
  end

  def find_policy(identifier, required: false)
    find error_key: 'Policy', required: required do
      company.policies.find_by(name: identifier)
    end
  end

  def find_department(identifier, required: false)
    find error_key: 'Department', required: required do
      company.departments.find_by(name: identifier)
    end
  end

  def find_location(identifier, required: false)
    find error_key: 'Location', required: required do
      company.locations.find_by(name: identifier)
    end
  end

  def find_cost_center(identifier, required: false)
    find error_key: 'Cost_center', required: required do
      company.cost_centers.find_by(name: identifier)
    end
  end

  def find_category(identifier, required: false)
    find error_key: 'Category', required: required do
      company.categories.find_by(name: identifier)
    end
  end

  def find_tax_rate(identifier, required: false)
    find error_key: 'Tax Rate', required: required do
      company.tax_rates.find_by(name: identifier)
    end
  end

  def find_bbps_biller(biller_id, required: false)
    find error_key: 'Biller', required: required do
      BbpsBiller.find_by(biller_id: biller_id)
    end
  end

end

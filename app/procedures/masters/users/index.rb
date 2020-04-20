class Masters::Users::Index < IndexBuilder::API

  resolver 'users.default'
  reference '{{record.id}}'

  column :name, label: 'Name', fixed: true, sort: :first_name do
    text value: "{{record.name}}", format: 'primary'
  end

  column :email, label: 'Email', fixed: true, sort: :email do
    text value: :email
  end

  column :mobile_number, label: 'Mobile Number', fixed: true, sort: :email do
    text value: :mobile_number
  end

  column :emp_id, label: 'Employee ID', sort: :profile_employee_id, default: true do
    text value: "{{record.profile.employee_id}}", format: 'primary'
  end

  column :created_at, sort: :created_at do
    date value: :created_at
  end

  column :status, default: true do
    indicator value: :user_status, format: :format_status
  end

  column :location, sort: :location_name, default: true do
    text value: "{{record.location.name}}"
  end

  column :department, sort: :department_name, default: true do
    text value: "{{record.department.name}}"
  end

  column :cost_center, sort: :cost_center_name, default: true do
    text value: "{{record.cost_center.name}}"
  end

  column :last_activity_at, sort: :last_activity_at, default: true do
    text value: -> (context) do
      user = context[:record]
      if user.last_activity_at
        days = (Time.now - user.last_activity_at).to_i / 1.day
        if days == 0
          'Today'
        elsif days == 1
          'Yesterday'
        else
          "#{days} days ago"
        end
      else
        'Never'
      end
    end
  end

  counter -> (user, collection) do
    counter = IndexBuilder::Counter.new :filter_state
    counter.add nil, "All", collection.count
    counter.add 1, "Active", collection.filter_state(1).count
    counter.add 2, "Pending", collection.filter_state(2).count
    counter.add 3, "Inactive", collection.filter_state(3).count
    counter
  end

  def self.user_status(context)
    user = context[:record]
    if user.active?
      'Active'
    elsif user.pending?
      'Pending'
    else
      'Inactive'
    end
  end

  def self.format_status(context)
    user = context[:record]
    if user.active?
      'success'
    elsif user.pending?
      'warning'
    else
      'danger'
    end
  end

end
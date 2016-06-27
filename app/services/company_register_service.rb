class CompanyRegisterService < BaseService
  attr_accessor :name, :logo
  attr_accessor :contact_name, :contact_email, :contact_number, :contact_designation
  attr_accessor :admin_name, :admin_email, :admin_number, :admin_password

  def initialize(name)
    super()
    self.name = name
  end

  def contact(contact_designation, contact_name, contact_email, contact_number)
    self.contact_designation =contact_designation
    self.contact_email =contact_email
    self.contact_name = contact_name
    self.contact_number = contact_number
  end

  def admin(admin_name, admin_email, admin_number, admin_password)
    self.admin_email = admin_email
    self.admin_number = admin_number
    self.admin_password = admin_password
    self.admin_name = admin_name
  end

  def register
    unless valid
      return false
    end
    # Create company and configure it
    company = Company.new(name: self.name)
    company.build_configuration
    if self.logo.present?
      company.configuration.logo = self.logo
    end

    unless company.save && company.configuration.save
      errors.add(company.errors.full_messages)
      errors.add(company.configuration.errors.full_messages)
      return false
    end
    company.reload

    # Create contact
    contact = company.contacts.build(email: self.contact_email, designation: self.contact_designation, name: self.contact_name, number: self.contact_number)

    # Create admin
    admin = company.users.build(name: admin_name, email: admin_email, user_type_id: 4, password: self.admin_password, password_confirmation: self.admin_password)

    if contact.save and admin.save
      return true
    end
    errors.add(contact.errors.full_messages)
    errors.add(admin.errors.full_messages)
    false
  end

  def check_valid(items)
    errors.clear
    items.each do |item|
      unless item.valid?
        errors.add(item.errors.full_messages)
      end
    end
    return false unless errors.blank?
    true
  end

  def valid
    errors.clear
    checker = [:name, :contact_name, :contact_email, :contact_number,
               :admin_name, :admin_email, :admin_number, :admin_password]
    checker.each do |item|
      item_val = self.send(item)
      if item_val.blank?
        errors.add "#{item.to_s.humanize} cannot be empty"
      end
    end
    return false unless errors.items.blank?
    true
  end

end
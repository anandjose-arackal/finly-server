class Invoicing::Customer::Import < Invoicing::Customer::Base

  attr_accessor :customers_data, :file, :headers, :data, :contents

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invalid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.file = params[:file]
    self.customers_data = ImportUtil.load_spreadsheet(file, [:name, :mobile_number, :email, :gst, :pan, :description,
                                                                  :address_name, :contact_name, :line_1, :line_2, :landmark, :city, :pin_code], {skip_empty_lines: true})
    self.headers = retrieve_headers
    self.contents = []
  end

  def validate
    if self.customers_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end
  end

  def process
    self.customers_data.each do |data|
      content = data.values
      retrieve_addresses_data(data)
      customer = user.company.customers.build(data)
      if customer.save
        content << "Successfully imported!"
      else
        content << customer.errors.full_messages.to_sentence
      end
      self.contents << content
    end
  end

  def post_process
    
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.contents}}, messages)
  end

  
  
  private

  def retrieve_addresses_data(customer_data)
    address_attributes = []
    address_attributes << customer_data.except(:name, :mobile_number, :email, :gst, :pan, :description, :contact_name)
    address_attributes.first[:name] = customer_data[:contact_name]
    customer_data[:addresses_attributes] = address_attributes
    [:address_name, :line_1, :line_2, :landmark, :city, :pin_code, :contact_name].each do |key|
      customer_data.delete(key)
    end
  end

  def retrieve_headers
    [
        "Full Name",
        "Mobile Number",
        "Email",
        "GSTIN",
        "PAN",
        "Description",
        "Address Name",
        "Contact Name",
        "Line 1",
        "Line 2",
        "Landmark",
        "City",
        "PIN"
    ]
  end
end
class Invoicing::Customer::Import < Invoicing::Customer::Base

  attr_accessor :customers_data, :file, :headers, :data

  def pre_validate
    if user.blank? || params.blank?
      add_message :error, "Invaoid parameters"
      return
    end
    if params[:file].blank?
      add_message :error, "No file uploaded"
    end
  end

  def init
    self.file = params[:file]
    self.customers_data = ImportUtil.load_spreadsheet(file, [:name, :mobile_number, :email, :gst, :pan, :description,
                                                                  :address_name, :name, :line_1, :line_2, :landmark, :city, :pin_code], {skip_empty_lines: true})
    self.headers = retrieve_headers
  end

  def validate
    if self.customers_data.blank?
      add_message :error, "Empty spreadsheet uploaded"
    end
  end

  def process
    self.customers_data.each do |data|
      retrieve_addresses_data(data)
      customer = Customer.new(data)
      if customer.save
        row = data
        row << "Successfully imported!"
        self.data << row
      else
        row = data
        row << customer.errors.full_messages.to_sentence
      end
    end
  end

  
  
  private

  def retrieve_addresses_data(customer_data)
    address_attributes = []
    address_attributes << customer_data.except(:name, :mobile_number, :email, :gst, :pan, :description)
    customer_data[:addresses_attributes] = address_attributes
    customer_data.delete(:address_name, :name, :line_1, :line_2, :landmark, :city, :pin_code)
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
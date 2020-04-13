class PaymentFiles::Formats::Denave::Process < PaymentFiles::Formats::BaseFormat

  attr_accessor :reports, :months, :pre_processed_request

  def pre_validate
    return if has_errors?
  end

  def validate

  end

  def init
    super
    group_mappings = self.params[:resources]
    self.reports = Report.with_processor_group_mapping(group_mappings.pluck(:id))
    self.pre_processed_request = {}
    self.months = []
    self.reports.each do |report|
      user = report.user
      expenses = report.expenses
      self.pre_processed_request[report] = {user: user} if self.pre_processed_request[report].nil?
      report_map = self.pre_processed_request[report]
      expenses.each do |expense|
        month_year = expense.date.strftime("%b-%y")
        report_map[month_year] = {} if report_map[month_year].nil?
        self.months << month_year unless self.months.include? month_year
        name = nil
        if expense.distance_expense?
          name = expense.distance_expense.vehicle_rate.vehicle_name
        elsif expense.manual_expense?
          name = expense.category.name
        end
        next if name.nil?
        amount = expense.amount.value
        if ['Internet', 'Mobile', 'Bike', 'Car'].include? name
          report_map[name] = {} if report_map[name].nil?
          report_map[name][month_year] = 0 if report_map[name][month_year].nil?
          report_map[name][month_year] += amount

          report_map[name]['total'] = 0 if report_map[name]['total'].nil?
          report_map[name]['total'] += amount
        else
          report_map[name] = 0 if report_map[name].nil?
          report_map[name] += amount
        end
      end
    end
  end

  def process
    self.headers = retrieve_denave_headers
    content = []
    pos = 0
    self.pre_processed_request.each do |report, details|
      total_expense = 0
      content_to_add = [
          (pos += 1),
          'D1111',
          report.user.name,
          "01-Apr-18",
          "Channel Manager",
          "OP-INFRA-1",
          "INFRA & FACILITIES",
          "OP-INFRA-1",
          "OP-INFRA-1",
          "OP-INFRA-1",
          "OP-INFRA-1",
          "INFRA and FACILITIES ",
          "Non Billable",
          "Actual",
          "INFRA and FACILITIES",
          "Delhi",
          "Delhi",
          "Working",
          report.user.bank_accounts.first.name,
          report.user.bank_accounts.first.account_number,
          report.user.bank_accounts.first.ifsc,
          report.user.email,
          7000
      ]
      conveyence_total = 0
      self.months.each do |month|
        content_to_add << details['Bike']&.dig(month)
        content_to_add << details['Car']&.dig(month)
        content_to_add << nil

        conveyence_total += (details['Bike']&.dig(month) || 0)
        conveyence_total += (details['Car']&.dig(month) || 0)
      end
      content_to_add << conveyence_total
      total_expense += conveyence_total || 0
      content_to_add << 2000
      internet_total = 0
      self.months.each do |month|
        content_to_add << details['Internet']&.dig(month)
        internet_total += details['Internet']&.dig(month) || 0
      end
      content_to_add << internet_total
      total_expense += internet_total || 0
      content_to_add << 1500
      mobile_total = 0
      self.months.each do |month|
        content_to_add << details['Mobile']&.dig(month)
        mobile_total += details['Mobile']&.dig(month) || 0
      end
      content_to_add << mobile_total
      total_expense += mobile_total || 0
      content_to_add << nil
      content_to_add << details['Team Motivational']
      total_expense += details['Team Motivational'] || 0
      content_to_add << details["Team Synergy"]
      total_expense += details["Team Synergy"] || 0
      content_to_add << details["Tour  (Conveyance)"]
      total_expense += details["Tour  (Conveyance)"] || 0
      content_to_add << details["Tour (Food)"]
      total_expense += details["Tour (Food)"] || 0
      content_to_add << details["Tour (Lodging)"]
      total_expense += details["Tour (Lodging)"] || 0
      content_to_add << total_expense
      content_to_add << nil
      content_to_add << nil
      content_to_add << total_expense
      content << content_to_add
      # headers + [ "Total (Cost)", "Advance", "Deduction", "Net Payable"]
    end
    # self.payment_file_data.each do |payment|
    #   content << [
    #       self.debit_account_number,
    #       payment[:beneficiary_account_number],
    #       payment[:receiving_user_name],
    #       payment[:amount],
    #       retrieve_payment_mode(payment),
    #       payment[:date],
    #       payment[:beneficiary_ifsc],
    #       "",
    #       "",
    #       payment[:receiving_mobile_number],
    #       payment[:receiving_user_email],
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       "",
    #       payment[:note],
    #       payment[:initiating_user_email]
    #   ]
    # Todo Remove the last entry of "payment[:initiating_user_email]", this was specifically built as per Toppr's requirements
    # end
    self.contents = content
  end

  def success
    generate_export_file
  end

  def retrieve_denave_headers
    headers = [
        "Sr No",
        "E-Code",
        "Employee Name",
        "DOJ",
        "Desig",
        "Division Code",
        "Division Name",
        "Client Code",
        "Client Name",
        "Program Code",
        "Project Code",
        "Project Name / Description (New) - Fin/ TKS/ HR / BD/ Admin",
        "Billable/Non-Billable",
        "Billing Type",
        "Deptt",
        "Location",
        "State",
        "Status",
        "Bank",
        "Account No.",
        "IFSC",
        "Mail-ID",
        "Conv-Limit"
    ]
    self.months.each do |month|
      headers << "#{month} - Bike"
      headers << "#{month} - Car"
      headers << "#{month} - Others"
    end
    headers << "Conveyance Total"
    headers << "Internet-Limit"
    self.months.each do |month|
      headers << month
    end
    headers << "Internet-Total"
    headers << "Mobile-Limit"
    self.months.each do |month|
      headers << month
    end
    headers << "Mobile-Total"
    headers + ["Others", "Team Motivational", "Team Synergy", "Tour  (Conveyance)", "Tour (Food) ", "Tour (Lodging)", "Total (Cost)", "Advance", "Deduction", "Net Payable"]
  end

  def retrieve_payment_mode(payment)
    case payment[:payment_mode].upcase
    when "NEFT"
      return "N"
    when "IMPS"
      return "I"
    when "RTGS"
      return "R"
    else
      # default to "N"
      return "N"
    end
  end
end
class Admin::Implementations::Master::Lurms::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lurms.import_template'

  headers ({
      :id => 'ID',
      :policy => 'Policy ID',
      :user_id => 'User Email / Mobile',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  PROVIDERS =%w(
             ReportProvider
             MoneyRequestProvider
             TravelRequestProvider
             TravelRequestBookingProvider
             PurchaseRequestProvider
             PurchaseOrderProvider
             PoInvoiceProvider
             NonPoInvoiceProvider
             BankPaymentRequestProvider
             )

  def valid_request
  end

  def input
    []
  end

  def post_process
  end

  def export(headers, contents)
    file = Tempfile.new(['lurm_import_template', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    PROVIDERS.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)

      headers.values.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      contents.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind

    temp_file = TemporaryFile.create file: file, expires_on: (DateTime.now.beginning_of_day + 1.day)
    temp_file.file.url
  end

end

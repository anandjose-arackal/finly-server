class Admin::Implementations::Master::Lurms::ImportTemplates < Admin::Implementations::Processor::ImportTemplate

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lurms.import_template'

  headers ({
      :id => 'ID',
      :policy => 'Policy Name',
      :policy_creation_flag => 'For New Policy Y / or Blank',
      :user_id => 'User Email / Mobile / Employee ID ',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile / Employee ID',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })


  def valid_request
  end

  def input
    []
  end

  def post_process
  end

  def export(headers, contents)
    providers =%w(
             ReportProvider
             MoneyRequestProvider
             TravelRequestProvider
             TravelRequestBookingProvider
             PurchaseRequestProvider
             PurchaseOrderProvider
             PoInvoiceProvider
             NonPoInvoiceProvider
             BankPaymentRequestProvider
             YesBankVendorProvider
             PaymentAgreementProvider
             AgreementInvoiceProvider
             BbpsBillerSubscriptionProvider
             BbpsBillProvider
             CreditNoteProvider
             )
    file = Tempfile.new(['lurm_import_template', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    providers.each  do |name|
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

class Admin::Implementations::Master::Lrms::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lrms.export'
  has_scope :with_id

  headers ({
      :id => 'ID',
      :policy => 'Policy Name',
      :policy_creation_flag => 'For New Policy Y / or Blank',
      :department_code => 'DepartmentCode',
      :location_code => 'LocationCode',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Reviewer Email / Mobile',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  def valid_request

  end

  def input

  end

  def process
    export(self.headers.values, contents)
  end

  def id(lrm)
    lrm.id
  end

  def policy(lrm)
    lrm.level&.policy&.name
  end

  def policy_creation_flag(lrm)
    ''
  end

  def level_number(lrm)
    lrm.level&.level_number
  end

  def department_code(lrm)
    ''
  end

  def location_code(lrm)
    ''
  end

  def level_name(lrm)
    lrm.level&.name
  end

  def reviewer_email_mobile(lrm)
    user = lrm.reviewer&.email
    if user.blank?
      lrm.reviewer&.mobile_number
    end
    user
  end

  def with_exception(lrm)
    lrm.exception? ? 'Y' :  'N'
  end

  def without_exception(lrm)
    lrm.wo_exception? ? 'Y' : 'N'
  end

  def min(lrm)
    lrm.min
  end

  def max(lrm)
    lrm.max
  end

  def destroy(lrm)
    ''
  end

  def post_process
  end

  def contents
    contents = {}
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
             BbpsBillerSubscriptionProvider
             BbpsBillProvider
             CreditNoteProvider
             )
    if params[:with_id] == "all"
      params[:with_id] = company.policies.pluck(:id)
    end
    providers.each do |provider|
      total_count = 0
      contents[provider] = []
      policy_ids = apply_scopes(company.policies).pluck(:id)
      level_ids  = ReviewalLevel.non_deleted.where(policy_id: policy_ids,associated_entity_type: provider).pluck(:id)
      data = LevelReviewerMapping.non_deleted.where(level_id: level_ids)
      total_count += data.count
      self.implementation_request.update(requested_items: data.count)
      data.each_with_index do |entry, index|
        row = []
        self.headers.keys.each do |field|
          row << self.send(field, entry)
        end
        contents[provider] << row
        item_complete true
      end
    end
    contents
  end

  def export(headers, contents)
    file = Tempfile.new(['lrm_export_result', '.xlsx'])
    workbook  = ::WriteXLSX.new(file)
    contents.each  do |name, sheet|
      worksheet = workbook.add_worksheet(name)

      headers.each_with_index do |item, index|
        worksheet.write( 0, index, item )
      end
      sheet.each_with_index do |items, row|
        items.each_with_index do |item, column|
          worksheet.write(1 + row, column, item)
        end
      end
    end
    workbook.close
    file.rewind
    self.implementation_request.result_file = file
    self.implementation_request.save
    progress_update(:completed)
  end

end

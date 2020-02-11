class Admin::Implementations::Master::Lurms::Export < Admin::Implementations::Processor::Export

  bus Admin::Implementations::Master::BaseMaster
  subscribe 'lurms.export'
  has_scope :with_id

  headers ({
      :id => 'ID',
      :policy => 'Policy Name',
      :policy_creation_flag => 'For New Policy Y / or Blank',
      :user_id => 'User Email / Mobile',
      :level_name => 'Level Name',
      :level_number => 'Level Number',
      :reviewer_email_mobile => 'Employee ID / Reviewer Email / Mobile',
      :with_exception => 'With Exception Y/N',
      :without_exception => 'Without Exception Y/N',
      :min => "Minimum Threshold",
      :max => "Max Threshold",
      :destroy => 'Destroy'
  })

  attr_accessor :providers, :total_count
  def valid_request

  end

  def input
  end

  def process
    export(self.headers.values, contents)
  end



  def id(lurm)
    lurm.id
  end

  def policy(lurm)
    lurm.level&.policy&.name
  end

  def policy_creation_flag(lurm)
    ''
  end

  def level_number(lurm)
    lurm.level&.level_number
  end

  def level_name(lurm)
    lurm.level&.name
  end

  def reviewer_email_mobile(lurm)
    identifier = lurm.reviewer&.profile&.employee_id
    if identifier.blank?
      identifier = lurm.reviewer&.email
    end
    if identifier.blank?
      identifier = lurm.reviewer&.mobile_number
    end
    identifier
  end

  def with_exception(lurm)
    lurm.exception? ? 'Y' :  'N'
  end

  def without_exception(lurm)
    lurm.wo_exception? ? 'Y' : 'N'
  end

  def user_id(lurm)
    identifier = lurm.reviewer&.profile&.employee_id
    return identifier if identifier.present?
    lurm.user&.email&.present? ? lurm.user&.email : lurm.user&.mobile_number
  end

  def min(lurm)
    lurm.min
  end

  def max(lurm)
    lurm.max
  end

  def destroy(lurm)
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


    if params[:with_id] == 'all'
      params[:with_id] = company.policies.pluck(:id)
    end
    providers.each do |provider|
      total_count = 0
      contents[provider] = []
      policy_ids = apply_scopes(company.policies).pluck(:id)
      level_ids  = ReviewalLevel.non_deleted.where(policy_id: policy_ids,associated_entity_type: provider).pluck(:id)
      data = LevelUserReviewerMapping.where(level_id: level_ids).where.not(user_id: nil).includes(:level, :policy,reviewer: :profile, user: :profile)
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
    file = Tempfile.new(['lurm_export_result', '.xlsx'])
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

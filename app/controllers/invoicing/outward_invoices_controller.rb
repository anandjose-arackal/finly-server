class Invoicing::OutwardInvoicesController < BaseControllers::WebBase

  before_action :set_tokens_in_header, only: [:download]

  def index
    @result = Invoicing::Invoice::Index.(current_user, params)
    respond
  end

  def count
    @result = Invoicing::Invoice::Count.(current_user, params)
    render json: @result.count.as_json
  end

  def show
    @result = Invoicing::Invoice::Show.(current_user, params)
    respond
  end

  def create
    @result = Invoicing::Invoice::Create.(current_user, params)
    respond
  end

  # this will save the current draft of the particular outward invoice (without submitting it)
  def update
    @result = Invoicing::Invoice::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def destroy
    @result = Invoicing::Invoice::Destroy.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def add_customer
    @result = Invoicing::Invoice::Customer::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def remove_customer
    @result = Invoicing::Invoice::Customer::Remove.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_address
    @result = Invoicing::Invoice::Address::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def update_virtual_account
    @result = Invoicing::Invoice::VirtualAccount::Update.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def save
    @result = Invoicing::Invoice::SaveInvoice.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  # Upload single attachment after the file has been selected
  def upload_attachment
    @result = Invoicing::Invoice::UploadAttachment.(current_user, params)
    if @result.success?
      respond
    else
      respond reponse: :failure, message: @result.messages[:error]
    end
  end

  def cancel
    @result = Invoicing::Invoice::Cancel.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def download
    @result = Invoicing::Invoice::DownloadInvoice.(current_user, params)
    @invoice = @result.invoice
    respond_to do |format|
      format.pdf {
          render pdf: "Invoice-#{@result.invoice.invoice_number}",
                 layout: "pdf.html.erb",
                 print_media_type: true,
                 margin: { :bottom => 5 },
                 footer: { html: { template: 'invoice_mailer/invoice_footer.html.erb' }}
      }
      format.html {}
    end
  end

  # def mark_as_closed
  #   @result = Invoicing::Invoice::MarkAsClosed.(current_user, params)
  #   if @result.success?
  #     respond response: :success, message: @result.messages[:success]
  #   else
  #     respond response: :failure, message: @result.messages[:error]
  #   end
  # end

  def record_payment
    @result = Invoicing::Invoice::RecordPayment.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def send_to_customer
    @result = Invoicing::Invoice::SendToCustomer.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

  def remind_customer
    @result = Invoicing::Invoice::RemindCustomer.(current_user, params)
    if @result.success?
      respond response: :success, message: @result.messages[:success]
    else
      respond response: :failure, message: @result.messages[:error]
    end
  end

end

class NotifierMailer < ApplicationMailer

  def send_mail(payload)
    @payload = JSON.parse(payload)

    # Payload Structure
    # payload = {
    #   record: model.as_json,
    #   company: company.as_json,
    #   action_user: action_user.as_json,
    # }

    # Attachments
    if @payload["attachments"].present?
      @payload["attachments"].each do |attachment|
        attachments[attachment[:name]] = WickedPdf.new.pdf_from_string(
            render_to_string(
                pdf: attachment[:name],
                # dpi: '650',
                encoding: 'UTF-8',
                template: attachment[:template],
                layout: attachment[:layout] || "pdf/paginated_bootstrap.html.erb",
                margin: {:bottom => 12},
                # layout: "pdf.html.erb",
                footer: {html: {template: attachment[:footer_template] || 'layouts/partials/_po_footer.html.erb'}},
            ),
            dpi: '650'
        )
      end
    end

    @payload["to"].compact && @payload["to"].compact.each do |email|
      mail to: email,
           # from: payload[:from],
           subject: @payload["subject"],
           template_name: 'template'
    end
    # mail to: 'abinash.b2@gmail.com', subject: presenter.subject, template_name: 'template'
  end

end
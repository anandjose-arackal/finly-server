WickedPdf.config = {
    exe_path: (Rails.env.development? ? `which wkhtmltopdf` : '/usr/local/bin/wkhtmltopdf')
}
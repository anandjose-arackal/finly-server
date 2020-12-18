require 'rails_helper'
# require "#{Rails.root}/spec/helpers/request_helper.rb"

RSpec.describe ExportManager::Template::TemplateExport do
  before :all do
    class TestExport < ExportManager::Builders::Template
      label 'Test label'
      description 'Test Description'
      export_format 'csv'
      resource 'invoices'
      subscribe 'invoices'
      default true
      roles [:admin, :finance_manager]
      attribute :invoice_number, template: '{{ record.invoice_number }}'
      attribute :finly_ref_no, template: '{{ record.invoice_id }}'
    end
  
    @company1 = create :company
    @user1 = create :vp_admin_user, company: @company1, mobile_number: generate(:user_mobile_number), email: generate(:finly_user_email), finly_id: 'test1'

    @invoice1 = create :invoice, company: @company1, created_by: @user1, invoice_number: '123456'
    
    @csv_template = ExportTemplateNew.where(company_id: @company1.id, master: 'TestExport').last

    ExportManager::Template::TemplateExport.sync!

    @json_template = ExportTemplateNew.create!(
      name: 'Template name',
      description: 'Template description',
      export_format: 'json',
      resource: 'invoices',
      template: '{"invoices": [{% for record in records %}{"invoice_id":"{{record.invoice_id}}","invoice_number":"{{record.invoice_number}}"},{% endfor %}]}',
      query: {},
      company: @company1
    )

    @xml_template = ExportTemplateNew.create!(
      name: 'Template name',
      description: 'Template description',
      export_format: 'xml',
      resource: 'invoices',
      template: '<xml>{% for record in records %}<Invoice><InvoiceID>{{record.invoice_id}}</InvoiceID><InvoiceNumber>{{record.invoice_number}}</InvoiceNumber></Invoice>{% endfor %}</xml>',
      query: {},
      company: @company1
    )
  end

  describe "CSV Export" do
    it "exports data correctly" do
      master_obj = ExportManager::Template::TemplateExport.new(@user1, {
        template_id: @csv_template.id
      })
      
      master_obj.perform
      export_job = master_obj.export_job
      expect(master_obj.export_job.present?).to eq true
      expect(master_obj.export_job.attachment.present?).to eq true
      expect(master_obj.file.present?).to eq true
      
      file_data = master_obj.file.read
      expect(file_data).to eq "Invoice number,Finly ref no\n#{@invoice1.invoice_number},#{@invoice1.invoice_id}\n"
    end
  end

  describe "JSON Export" do
    it "exports data correctly" do
      master_obj = ExportManager::Template::TemplateExport.new(@user1, {
        template_id: @json_template.id
      })
      
      master_obj.perform
      export_job = master_obj.export_job
      expect(master_obj.export_job.present?).to eq true
      expect(master_obj.export_job.attachment.present?).to eq true
      expect(master_obj.file.present?).to eq true
      
      file_data = master_obj.file.read
      expect(file_data).to eq "{\"invoices\": [{\"invoice_id\":\"#{@invoice1.invoice_id}\",\"invoice_number\":\"#{@invoice1.invoice_number}\"},]}"
    end
  end

  describe "JSON Export" do
    it "exports data correctly" do
      master_obj = ExportManager::Template::TemplateExport.new(@user1, {
        template_id: @xml_template.id
      })
      
      master_obj.perform
      export_job = master_obj.export_job
      expect(master_obj.export_job.present?).to eq true
      expect(master_obj.export_job.attachment.present?).to eq true
      expect(master_obj.file.present?).to eq true
      
      file_data = master_obj.file.read
      expect(file_data).to eq "<xml><Invoice><InvoiceID>#{@invoice1.invoice_id}</InvoiceID><InvoiceNumber>#{@invoice1.invoice_number}</InvoiceNumber></Invoice></xml>"
    end
  end

end

# now that the import should include custom fields that belong to a particular company,
# it will need to be dynamically generated
class Procurements::Invoices::ImportTemplate < Procurements::Invoices::Base

  attr_accessor :company, :invoice_custom_fields, :sample_type,
                :headers, :content, :sheets, :attachments,
                :import_data # will be passed from import operation

  def init
    self.company = user.company
    self.invoice_custom_fields = self.company.field_configurations.non_deleted.with_field_parent_type(FieldParentType.id_for(:invoice))
    attachment_op = Procurements::Attachments::Index.(user, params)
    if attachment_op.success?
      self.attachments = attachment_op.attachments
    end

    if params[:import_data].present?
      self.import_data = params[:import_data]
    end
    # self.sample_type = params[:sample_type]
  end

  def process
    self.headers = default_headers
    self.content = []
    # todo change below for getting inventory line item custom fields
    self.invoice_custom_fields.each do |custom_field_config|
      case custom_field_config.field_type_id
        when FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)
          self.headers << "#{custom_field_config.field_name} ID"
        else
          self.headers << "#{custom_field_config.field_name}"
      end
    end
    self.sheets = [
        {
            item_headers: self.headers,
            item_contents: import_data.present? ? import_data[:contents] : []
        }
    ]


    ##################################################
    # adding Categories to the excel sheet
    # category_headers = ["ID", "Category Name"]
    # category_contents = []
    #
    # # todo only fetch categories for collect and vendor payments line items
    # user.company.categories.active.each do |category|
    #   category_contents << [category.id, category.name]
    # end
    # self.sheets << {
    #     item_headers: category_headers,
    #     item_contents: category_contents,
    #     name: "Categories",
    #
    # }

    ##################################################
    # Add Non PO items list
    op = Invoicing::InventoryLineItem::Index.(user, {filter_item_type: [SupplyItemType.id_for(:non_po_item)]})
    items = op.inventory_line_items

    item_headers = ["ID", "Description", "Category", "Rate", "Tax Rate", "Discount" "Note"]
    item_contents = []

    items.each do |item|
      item_contents << [item.id, item.description, item.category&.name, item.rate, item.tax_rate&.rate, item.discount, item.note]
    end

    self.sheets << {
        item_headers: item_headers,
        item_contents: item_contents,
        name: 'Non PO Items'
    }


    ##################################################
    # adding Tax Rates to the Excel sheet
    tax_rate_headers = ["ID", "Tax Rate Name", "Rate %", "Internal ID"]
    tax_rate_contents = []
    user.company.tax_rates.each do |tax_rate|
      tax_rate_contents << [tax_rate.id, tax_rate.name, tax_rate.rate, tax_rate.internal_id]
    end
    self.sheets << {
        item_headers: tax_rate_headers,
        item_contents: tax_rate_contents,
        name: "Tax Rates"
    }

    ##################################################
    # adding custom fields to the excel sheet
    self.invoice_custom_fields.with_field_type([FieldType.id_for(:drop_down), FieldType.id_for(:multiselect)]).each do |custom_field_config|
      custom_field_headers = ["#{custom_field_config.field_name} ID", "#{custom_field_config.field_name} Name"]
      case custom_field_config.field_type_id
        when FieldType.id_for(:drop_down)
          selection_items = custom_field_config.drop_down_items
        when FieldType.id_for(:multiselect)
          selection_items = custom_field_config.multiselect_items
        else
          selection_items = []
      end
      custom_field_contents = []
      selection_items.each do |content|
        custom_field_contents << [content.id, content.name]
      end
      self.sheets << {
          item_headers: custom_field_headers,
          item_contents: custom_field_contents,
          name: custom_field_config.field_name
      }
    end

    ##################################################
    # Add Payment terms
    payment_term_headers = ["Payment Term Name"]
    payment_term_contents = []
    user.company.payment_terms.each do |payment_term|
      payment_term_contents << [payment_term.name]
    end

    self.sheets << {
        item_headers: payment_term_headers,
        item_contents: payment_term_contents,
        name: 'Payment Terms'
    }

    ##################################################
    # Add Sub Departments
    sub_department_headers = ["Sub Department Name"]
    sub_department_contents = []
    user.departments.only_sub_departments.each do |department|
      sub_department_contents << [department.name]
    end
    self.sheets << {
        item_headers: sub_department_headers,
        item_contents: sub_department_contents,
        name: 'Sub Departments'
    }

    ##################################################
    # Add Departments
    # department_headers = ["ID", "Department Name"]
    # department_contents = []
    # user.company.departments.roots.each do |department|
    #   department_contents << [department.id, department.name]
    # end
    #
    # self.sheets << {
    #     item_headers: department_headers,
    #     item_contents: department_contents,
    #     name: 'Departments'
    # }

    ##################################################
    # Add Cost Centers
    # cost_center_headers = ["ID", "Cost Center Name"]
    # cost_center_contents = []
    # user.company.cost_centers.each do |cc|
    #   cost_center_contents << [cc.id, cc.name]
    # end
    #
    # self.sheets << {
    #     item_headers: cost_center_headers,
    #     item_contents: cost_center_contents,
    #     name: 'Cost Centers'
    # }

    ##################################################
    # Add Locations
    location_headers = ["ID", "Location Name", "Address"]
    location_contents = []
    user.company.locations.each do |location|
      location_contents << [location.id, location.name, location.address]
    end

    self.sheets << {
        item_headers: location_headers,
        item_contents: location_contents,
        name: 'Locations'
    }

    ##################################################
    # Add Policies
    policies_headers = ["Policy Name"]
    policies_contents = []
    user.policies.with_application(:vp).each do |policy|
      policies_contents << [policy.name]
    end

    self.sheets << {
        item_headers: policies_headers,
        item_contents: policies_contents,
        name: 'Policies'
    }

    ##################################################
    # add attachments to invoice
    if self.attachments.present?
      attachment_headers = ["Attachment ID", "File Name", "Description", "View in Browser"]
      attachment_contents = []

      self.attachments.each do |attachment|
        attachment_contents << [attachment.id, attachment.file.original_filename, attachment.description, attachment.file.url]
      end
      self.sheets << {
          item_headers: attachment_headers,
          item_contents: attachment_contents,
          name: "Attachment Details",

      }
    end
  end

  def success
    self.response = Exporter.new(user, {spreadsheet: {headers: self.headers, contents: self.content, sheets: self.sheets, template: 'export_template/template_w_validation'}}, messages)
  end

  private

  def default_headers
    if import_data.present?
      import_data[:headers]
    else

      [
          "Vendor ID",
          "Invoice Number",
          "Invoice Date",
          "Due Date",
          "Payment Term Name",
          "Item Id",
          "Description",
          "Qty",
          "Amount",
          "Tax Rate ID",
          "Total",
          "Period",
          "Attachment ID",
          "Policy Name",
          "Sub Department Name",
          "Billing Location ID",
          "Shipping Location ID",
          "Auto Submit (Yes/No)"
      ]
    end
  end
end
class Category::Invoicing::Index < Category::Invoicing::Base

  attr_accessor :invoice_categories, :invoice_line_items_categories, :invoice_custom_fields, :invoice_line_items_custom_fields,
                :company, :invoice_purpose_id, :invoice_line_items_purpose_id

  class Category::Invoicing::Index::CategoriesPresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :invoice_categories, :invoice_line_items_categories, :invoice_custom_fields, :invoice_line_items_custom_fields

    def init
      self.invoice_categories = params[:invoice_categories]
      self.invoice_line_items_categories = params[:invoice_line_items_categories]
      self.invoice_custom_fields = params[:invoice_custom_fields]
      self.invoice_line_items_custom_fields = params[:invoice_line_items_custom_fields]
    end

  end

  def init
    self.company = user.company
    self.invoice_purpose_id = Purpose.id_for(:invoicing)
    self.invoice_line_items_purpose_id = Purpose.id_for(:invoice_line_items)
  end


  def process
    self.categories = self.company.categories.with_purpose(self.invoice_purpose_id)
    self.invoice_line_items_categories = self.categories.with_purpose(self.invoice_line_items_purpose_id)
    self.invoice_custom_fields = self.company.field_configurations.with_parent_type(FieldParentType.id_for(:invoice))
    self.invoice_line_items_custom_fields = self.company.field_configurations.with_parent_type(FieldParentType.id_for(:invoice_line_item))
  end

  def success
    params[:invoice_categories] = self.invoice_categories
    params[:invoice_line_items_categories] = self.invoice_line_items_categories
    params[:invoice_custom_fields] = self.invoice_custom_fields
    params[:invoice_line_items_custom_fields] = self.invoice_line_items_custom_fields
  end

end
class Procurements::DocumentNumbers::Generate < Procurements::DocumentNumbers::Base
  attr_accessor :number_config, :document_number, :document, :document_type, :purpose_id, :number_config_type_id, :invoice_type, :company

  class Procurements::DocumentNumbers::Generate::GeneratePresenter < BaseOperation::BasePresenter::SuccessPresenter

    attr_accessor :document_number

    def init
      self.document_number = params[:document_number]
    end
  end

  def init
    self.company = user.company
    self.document = params[:document]
    if self.document.is_a?(PurchaseOrder)
      self.number_config_type_id = DocumentNumberConfigType.id_for(:purchase_order)
      self.document_type = :purchase_order
      # self.number_config = DocumentNumberConfig.with_company_id(company.id).with_config_type_id(number_config_type_id)
    elsif self.document.is_a?(InwardDocument)
      self.number_config_type_id = DocumentNumberConfigType.id_for(:inward_document)
      self.document_type = :inward_document
      # self.number_config = DocumentNumberConfig.with_company_id(company.id).with_config_type_id(number_config_type_id)
    else
      add_message :error, "Invalid purpose passed"
      return
    end

    self.number_config = user.company.document_number_configs.with_config_type_id(number_config_type_id).first
  end

  def validate
    if self.number_config.blank?
      add_message :error, "Invoice number generation is not enabled for your company"
      return
    end
  end

  def process
    self.document_number = ""
    if self.number_config.prefix.present?
      self.document_number = self.number_config.prefix || ""
    end

    case self.document_type
      when :purchase_order
        iteration = 1
        loop do
          self.document_number = ""
          if self.number_config.prefix.present?
            self.document_number = self.number_config.prefix
          end

          if self.number_config.sequence_start.present?
            last_document = user.company.purchase_orders.document_number_generated_in_finly.valid.reorder(created_at: :desc).first
            if last_document.present? && last_document.created_at > self.number_config.updated_at
              prefix = self.number_config.prefix
              numeric_section = last_document.po_number&.gsub(prefix, '') || '000'
              new_numeral = numeric_section
              iteration.times do
                new_numeral = new_numeral.succ
              end
              self.document_number += new_numeral.to_s
            elsif (last_document.present? && last_document.created_at <= self.number_config.updated_at) || last_document.blank?
              numeric_section = self.number_config.sequence_start
              new_numeral = numeric_section
              iteration.times do
                new_numeral = new_numeral.succ
              end
              self.document_number += new_numeral.to_s
            end
          end

          if user.company.purchase_orders.find_by po_number: self.document_number
            iteration += 1
          else
            break
          end
        end








        # # todo add valid
        # # last_document = user.company.purchase_orders.document_number_generated_in_finly.valid.reorder(created_at: :desc).first
        # last_document = user.company.purchase_orders.document_number_generated_in_finly.valid.reorder(created_at: :desc).first
        #
        # if self.number_config.sequence_start.present?
        #   if last_document.present? && last_document.created_at > self.number_config.updated_at
        #     self.document_number = last_document.po_number || (self.document_number + self.number_config.sequence_start)
        #     self.document_number = self.document_number.succ
        #   elsif (last_document.present? && last_document.created_at <= self.number_config.updated_at) || last_document.blank?
        #     self.document_number = self.document_number + self.number_config.sequence_start
        #     self.document_number = self.document_number.succ
        #   end
        # end
      when :inward_document
        # last_document = user.company.inward_documents.document_number_generated_in_finly.valid.reorder(created_at: :desc).first
        last_document = user.company.inward_documents.document_number_generated_in_finly.reorder(created_at: :desc).first
        if self.number_config.sequence_start.present?
          if last_document.present? && last_document.created_at > self.number_config.updated_at
            prefix = last_document.prefix || self.number_config.prefix
            numeric_section = last_document.document_number.gsub(prefix, '')
            new_numeral = numeric_section
            iteration.times do
              new_numeral = new_numeral.succ
            end
            self.document_number += new_numeral.to_s
          elsif (last_document.present? && last_document.created_at <= self.number_config.updated_at) || last_document.blank?
            numeric_section = self.number_config.sequence_start
            new_numeral = numeric_section
            iteration.times do
              new_numeral = new_numeral.succ
            end
            self.document_number += new_numeral.to_s
          end
        end
    end
  end

  def success
    params[:document_number] = self.document_number
    Procurements::DocumentNumbers::Generate::GeneratePresenter.new(user, params, messages)
  end
end
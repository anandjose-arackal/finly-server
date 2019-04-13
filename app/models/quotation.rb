# Schema Information
# Table Name = Quotations
# -----------------------
# 
#                      :id => :integer,
#             :vendor_name => :string,
#         :vendor_location => :string,
# :estimated_delivery_time => :string,
#            :total_amount => :decimal,
#          :advance_amount => :decimal,
#           :credit_period => :string,
#                    :note => :text,
#                :selected => :boolean,
#              :created_at => :datetime,
#              :updated_at => :datetime,
#       :purchase_order_id => :integer,
#              :is_deleted => :boolean,
#              :deleted_at => :datetime,
#        :quotation_number => :string



class Quotation < ApplicationRecord
	include SoftDeletable
	# include Sequenced::ActsAsSequenced

 #  	acts_as_sequenced column: :quotation_number, purpose: :quotation, editable: false, prefix: 'Q-'

	belongs_to :purchase_order, optional: true
	has_many :attachments, class_name: "ProcurementAttachment", as: :procurement_document

	validates :vendor_name, length: {minimum: 3, maximum: 50}
	validates :vendor_location, length: {minimum: 3, maximum: 100}
	validates_presence_of :total_amount
	# validates :note, length:{minimum:5}, allow_blank: true

	accepts_nested_attributes_for :attachments, allow_destroy: true


	def as_json
		{

            id: self.id,
            vendor_name: self.vendor_name,
            vendor_location: self.vendor_location,
            estimated_delivery_time: self.estimated_delivery_time,
            total_amount: self.total_amount,
            advance_amount: self.advance_amount,
            credit_period: self.credit_period,
            note: self.note,
            selected: self.selected,
            purchase_order: self.purchase_order_id

        }
	end
end

# release/forms#rich_text_editor_procurement_term
class FormsRichTextEditorProcurementTermToggle < ApplicationToggle
    def enabled?
      feature_flag 'release/forms#rich_text_editor_procurement_term', false
    end
end
  
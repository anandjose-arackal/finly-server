class Forms::Rules::Predicates

  NAMES = %w(
      eq eq_any eq_all
      not_eq not_eq_any not_eq_all
      matches matches_any matches_all
      does_not_match does_not_match_any does_not_match_all
      lt lt_any lt_all
      lteq lteq_any lteq_all
      gt gt_any gt_all
      gteq gteq_any gteq_all
      in in_any in_all
      not_in not_in_any not_in_all
      cont cont_any cont_all
      not_cont not_cont_any not_cont_all
      start start_any start_all
      not_start not_start_any not_start_all
      end end_any end_all
      not_end not_end_any not_end_all
      true
      false
      present
      blank
      null
      not_null
    )

  def self.basic
    NAMES.reject {|predicate| predicate.end_with?('_any') or predicate.end_with?('_all')}
  end

  def self.all
    NAMES
  end
end
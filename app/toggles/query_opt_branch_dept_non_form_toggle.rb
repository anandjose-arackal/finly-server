# release/query_opt_branch_dept_non_form
class QueryOptBranchDeptNonForm < ApplicationToggle

  def enabled?
    feature_flag 'release/query_opt_branch_dept_non_form', false
  end

end
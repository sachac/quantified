module ApplicationHelper
  def set_focus_to_id(id)
    javascript_tag("$('#{id}').focus()");
  end
end

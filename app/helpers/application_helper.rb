module ApplicationHelper
  # Returns the full title on a per-page basis.
  def full_title(page_title)
    base_title = "Project Credo"
    if page_title.empty?
      base_title
    else
      "#{page_title} - #{base_title}"
    end
  end

  def meta_description(page_title)
    base_description = "Find out on Project Credo!"
    if page_title.empty?
      tag 'meta', description: base_description
    else
      tag 'meta', description: "#{page_title} - #{base_description}"
    end
  end
end


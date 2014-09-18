module ResearchesHelper
  def yes_or_no(boolean)
    boolean ? "Yes" : "No"
  end

  def is_it?(boolean)
    boolean ? "" : "Not"
  end

end

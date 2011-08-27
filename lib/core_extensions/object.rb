class String
  def is_numeric?
    Float self rescue false
  end
end

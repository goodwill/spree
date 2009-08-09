module SearchFormHelper
  def join_keywords(keywords)
    keywords
    keywords.join(" ") if keywords.is_a? Array
  end
end
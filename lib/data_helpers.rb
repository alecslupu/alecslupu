# frozen_string_literal: true

module DataHelpers

  # Clean an HTML string from image tags
  # Used for the blog snippets or summaries in the homepage
  #
  # @param html [String] HTML with the string that needs to be cleaned up
  # @return [String]
  def strip_img(html)
    doc = Nokogiri::HTML(html)
    doc.search(".//img").remove
    doc.to_html
  end
end

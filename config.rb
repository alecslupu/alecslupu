# Activate and configure extensions
# https://middlemanapp.com/advanced/configuration/#configuring-extensions

require "debug"
require "lib/icon_helpers"
helpers IconHelpers

# Blog
activate :blog do |blog|
  blog.paginate = true

  blog.page_link = "p{num}"
  blog.per_page = 2


  blog.layout = "blog_layout"
  blog.permalink = "blog/{year}-{month}-{day}-{title}.html"
  blog.sources = "blog/en/{year}-{month}-{day}-{title}.html"
  blog.default_extension = ".md"
  blog.tag_template = "blog/tag.html"
  blog.calendar_template = "blog/calendar.html"
  blog.custom_collections = {
    category: {
      link: '/categories/{category}.html',
      template: 'blog/category.html'
    }
  }
end

# Reload the browser automatically whenever files change
configure :development do
  activate :livereload
end

activate :external_pipeline,
         name: :tailwindcss,
         command: "./node_modules/tailwindcss/lib/cli.js --postcss -i ./source/stylesheets/site.css -o ./source/stylesheets/tailwind.css #{build? ? "--minify" : "--watch"}",
         source: "source/stylesheets",
         latency: 1

activate :autoprefixer do |prefix|
  prefix.browsers = "last 2 versions"
end

# Layouts
# https://middlemanapp.com/basics/layouts/

# Per-page layout changes
page '/*.xml', layout: false
page '/*.json', layout: false
page '/*.txt', layout: false

# With alternative layout
# page '/path/to/file.html', layout: 'other_layout'

# Proxy pages
# https://middlemanapp.com/advanced/dynamic-pages/

# proxy(
#   '/this-page-has-no-template.html',
#   '/template-file.html',
#   locals: {
#     which_fake_page: 'Rendering a fake page with a local variable'
#   },
# )

# Helpers
# Methods defined in the helpers block are available in templates
# https://middlemanapp.com/basics/helper-methods/

# helpers do
#   def some_helper
#     'Helping'
#   end
# end

# Build-specific configuration
# https://middlemanapp.com/advanced/configuration/#environment-specific-settings

# configure :build do
#   activate :minify_css
#   activate :minify_javascript, compressor: Terser.new
# end

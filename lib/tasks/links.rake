namespace :links do
  desc 'Generate links between pages'
  task load: :environment do
    # Get all pages
    pages = Page.all

    # Loop through each page
    pages.each do |page|
      
      source_links = page.source.scan(/\[\[(.*?)\]\]/).flatten
      source_links.each do |link_title|
        linked_page = Page.find_by(title: link_title)
        if linked_page.present?
          Link.find_or_create_by(link_type: :source, from_page: page, to_page: linked_page)
        else
          puts "Source link not found: #{link_title}"
        end
      end

      relevant_links = (page.relevant + page.content).scan(/\[\[(.*?)\]\]/).flatten
      relevant_links.each do |link_title|
        linked_page = Page.find_by(title: link_title)
        if linked_page.present?
          Link.find_or_create_by(link_type: :relevant, from_page: page, to_page: linked_page)
        else
          puts "Relevant link not found: #{link_title}"
        end
      end
    end
  end
end

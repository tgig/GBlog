namespace :pages do
  desc 'Load markdown files from lib/assets into the database'
  task load: :environment do

    # WARNING THIS REMOVES ALL CONTENT INCLUDING CALLBACKS BEFORE RE-INSERTING IT
    Link.destroy_all
    Page.destroy_all
    ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'links';")
    ActiveRecord::Base.connection.execute("UPDATE sqlite_sequence SET seq = 0 WHERE name = 'pages';")

    # ----------------------------------
    # PAGE

    root_path = 'lib/assets'
    folder_colors = {}
    ['nodes', 'posts'].each do |dir|
      Dir.glob("#{root_path}/#{dir}/**/*.md").each do |markdown_file_path|
        title = File.basename(markdown_file_path, '.md')
        markdown_content = File.read(markdown_file_path)
        
        # Split the markdown content into header and body
        header, body = markdown_content.split(/^#/, 2)
        body = "##{body}" if body.present?
        
        # Parse header for source, relevant, and publish_date
        source_match = header.scan(/^source:(.*?)^(?:\w+:|$)/m).join.strip
        relevant_match = header.scan(/^relevant:(.*?)^(?:\w+:|$)/m).join.strip
        date_match = header.scan(/^publish_date:(.*?)^(?:\w+:|$)/m).join.strip

        this_folder_name = folder_name(markdown_file_path, root_path, dir)

        unless folder_colors.has_key?(this_folder_name)
          folder_colors[this_folder_name] = get_rand_color
        end

        color = folder_colors[this_folder_name]

        page = Page.create!(
          page_type: dir.singularize,
          file_path: markdown_file_path,
          folder: this_folder_name,
          folder_id: this_folder_name.parameterize,
          title: title,
          title_id: title.parameterize,
          source: source_match,
          relevant: relevant_match,
          content: body&.strip,
          weight: 0,
          color: color
        )

        page.update!(updated_at: Date.parse(date_match)) if date_match.present?

        puts "Loaded #{markdown_file_path}"
      end
    end

    # ----------------------------------
    # LINK

    # Get all pages
    pages = Page.all

    # Loop through each page
    pages.each do |page|
      
      source_links = page.source.scan(/\[\[(.*?)\]\]/).flatten
      source_links && source_links.each do |link_title|
        link_title = link_title.split('|')[0] if link_title.include?('|')
        linked_page = Page.find_by(title: link_title)
        if linked_page.present?
          Link.find_or_create_by(link_type: :source, from_page: page, to_page: linked_page)
        else
          puts "Source link not found: #{link_title}"
        end
      end

      relevant_links = (page&.relevant.to_s + page&.content.to_s).scan(/\[\[(.*?)\]\]/).flatten
      relevant_links && relevant_links.each do |link_title|
        link_title = link_title.split('|')[0] if link_title.include?('|')
        linked_page = Page.find_by(title: link_title)
        if linked_page.present?
          Link.find_or_create_by(link_type: :relevant, from_page: page, to_page: linked_page)
        else
          puts "Relevant link not found: #{link_title}"
        end
      end
    end

  end

  def folder_name(markdown_file_path, root_path, dir)
    markdown_file_path.gsub("#{root_path}/#{dir}/", '').split('/')[0]
  end

  def get_rand_color
    # Randomizing the hue
    h, s, l = rand, 0.78, 0.59

    # Convert HSL to RGB
    rgb = Color::HSL.from_fraction(h, s, l).to_rgb

    # Normalize RGB values to the range 0-255
    # r, g, b = (rgb.red * 255).to_i, (rgb.green * 255).to_i, (rgb.blue * 255).to_i
    r, g, b = rgb.red.to_i, rgb.green.to_i, rgb.blue.to_i

    # Return RGB values in hexadecimal format
    return sprintf('#%02x%02x%02x', r, g, b)
  end

end

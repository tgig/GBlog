class NodesController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  def index
    @folders = Page.where(page_type: 'node').group(:folder).count
  end

  def folder
    @folder_id = node_params[:folder_id]
    @pages = Page.where(folder_id: @folder_id, page_type: 'node')
    raise ActiveRecord::RecordNotFound if @pages.empty?
  end

  def page
    @page = Page.find_by!(title_id: node_params[:title_id])
    @link_graph, @page_graph = get_link_and_page_graph
    htmlize
  end

  def graph
    link_graph, page_graph = get_link_and_page_graph
    render json: { links: link_graph, pages: page_graph }
    # render json: d3_node_graph(link_graph, page_graph)
  end

  def get_link_and_page_graph

    # Step 1: Retrieve the initial set of pages based on folder_id and optionally title_id
    if node_params[:title_id].present? && node_params[:title_id] == "index"
      pages = Page.all
    elsif node_params[:folder_id].present? && node_params[:title_id] == "folder"
      pages = Page.where(folder_id: node_params[:folder_id]) 
    elsif node_params[:title_id].present?
      pages = Page.where(title_id: node_params[:title_id])
    else
      raise ActiveRecord::RecordNotFound
    end

    # Step 2: Get the links for those pages
    page_ids = pages.pluck(:id)
    links = Link.where(from_page_id: page_ids).or(Link.where(to_page_id: page_ids))
    link_graph = links.map do |link|
      {
        source: link.from_page_id,
        target: link.to_page_id
      }
    end

    # Step 3: Get all the pages contained in the links
    linked_page_ids = links.pluck(:from_page_id, :to_page_id).flatten.uniq
    linked_pages = Page.where(id: linked_page_ids)
    page_graph = linked_pages.map do |page|
      { 
        id: page.id,
        page_rank: page.page_rank,
        color: page.color,
        folderId: page.folder_id,
        folderName: page.folder,
        fileName: page.title,
        url: "/#{page.folder_id}/#{page.title_id}"
      }
    end

    [link_graph, page_graph]

  end

  private

  def render_404
    render file: "#{Rails.root}/public/404.html", status: :not_found
  end

  # def replace_bracket_links
  #   @page.content.gsub(/\[\[(.*?)\]\]/) do |match|
  #     get_html_link($1)  # $1 contains the matched content inside the brackets
  #   end
  # end

  def htmlize
    htmlize_source
    htmlize_content
  end

  def htmlize_source
    source = @page.source

    # turn [[link]] into <a href>
    source = source.gsub(/\[\[(.*?)\]\]/) do |match|
      get_html_link($1)
    end

    source = Kramdown::Document.new(source).to_html

    @page.source = source
  end

  def htmlize_content
    content = @page.content

    # turn [[link]] into <a href>
    content = content.gsub(/\[\[(.*?)\]\]/) do |match|
      get_html_link($1)
    end

    content = Kramdown::Document.new(content).to_html

    @page.content = content
  end

  def get_html_link(link_title)
    link_title = remove_square_brackets(link_title)
    link_title, link_text = link_title.split('|')
    
    linked_page = Page.find_by(title: link_title)

    link_text = link_title if link_text.blank?
    
    if linked_page.present?
      "[#{link_text}](/#{linked_page.folder_id}/#{linked_page.title_id})"
    else
      puts "ERROR: Link not found: #{link_title}"
    end
  end

  def remove_square_brackets(str)
    str.gsub(/\[\[(.*?)\]\]/, '\1')
  end

  def node_params
    params.permit(:folder_id, :title_id)
  end

end

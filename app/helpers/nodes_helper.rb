module NodesHelper
  def graph_link_element(link, page_graph, current_page)
    from = find_page_by_id(page_graph, link[:source])
    to = find_page_by_id(page_graph, link[:target])

    from_title = link_to_page(from, current_page)
    to_title = link_to_page(to, current_page)

    "#{from_title} to #{to_title}".html_safe
  end

  private

  def find_page_by_id(page_graph, id)
    page_graph.find { |element| element[:id] == id }
  end

  def link_to_page(page, current_page)
    return page[:fileName] if page[:id] == current_page.id

    link_to(page[:fileName], page[:url])
  end
end

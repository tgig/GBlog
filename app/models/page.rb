class Page < ApplicationRecord
  enum page_type: { node: 0, post: 1 }

  has_many :outgoing_links, class_name: 'Link', foreign_key: 'from_page_id', dependent: :destroy
  has_many :incoming_links, class_name: 'Link', foreign_key: 'to_page_id', dependent: :destroy

  def self.calculate_page_rank
    # Step 1: Initialize PageRank for all pages based on the number of incoming links
    Page.find_each do |page|
      incoming_links_count = page.incoming_links.count
      page.update(page_rank: incoming_links_count)
    end
  
    # Calculate PageRank for each iteration
    incoming_page_ranks = []
    Page.find_each do |page|
      sum_of_ranks = page.incoming_links.includes(:from_page).sum { |link| link.from_page.page_rank }
      incoming_page_ranks << [page.id, sum_of_ranks]
    end

    # Normalize values between 0 and 100
    max_rank = incoming_page_ranks.map(&:last).max.to_f
    normalized_ranks = incoming_page_ranks.map { |id, rank| [id, (rank / max_rank) * 100] }

    # Update PageRank for each page
    normalized_ranks.each do |id, normalized_rank|
      Page.find(id).update(page_rank: normalized_rank)
    end
  end
  
end

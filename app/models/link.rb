class Link < ApplicationRecord
  enum link_type: { source: 0, relevant: 1 }

  belongs_to :from_page, class_name: 'Page', foreign_key: 'from_page_id'
  belongs_to :to_page, class_name: 'Page', foreign_key: 'to_page_id'
end

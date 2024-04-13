Rails.application.routes.draw do
  # Redirect old pages
  get 'miki/:old_id', to: 'nodes#old_to_new', constraints: { old_id: /.*/ }

  get 'nodes/index'
  get ':folder_id', to: 'nodes#folder', as: 'folder'
  get ':folder_id/:title_id', to: 'nodes#page', as: 'page'
  get ':folder_id/:title_id/graph', to: 'nodes#graph', as: 'graph'

  root "nodes#index"
end

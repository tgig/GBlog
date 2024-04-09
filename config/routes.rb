Rails.application.routes.draw do
  get 'nodes/index'
  get ':folder_id', to: 'nodes#folder', as: 'folder'
  get ':folder_id/:title_id', to: 'nodes#page'
  
  # get ':folder_id/graph', to: 'nodes#graph'
  get ':folder_id/:title_id/graph', to: 'nodes#graph'

  root "nodes#index"
end

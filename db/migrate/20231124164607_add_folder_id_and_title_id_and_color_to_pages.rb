class AddFolderIdAndTitleIdAndColorToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :folder_id, :string
    add_column :pages, :title_id, :string
    add_column :pages, :color, :string
  end
end

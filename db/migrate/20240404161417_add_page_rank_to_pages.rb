class AddPageRankToPages < ActiveRecord::Migration[7.1]
  def change
    add_column :pages, :page_rank, :float
    remove_column :pages, :weight, :integer
  end
end

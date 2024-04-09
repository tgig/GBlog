class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.integer :page_type
      t.string :file_path
      t.string :folder
      t.string :title
      t.text :source
      t.text :relevant
      t.text :desc
      t.text :content
      t.integer :weight

      t.timestamps
    end
  end
end

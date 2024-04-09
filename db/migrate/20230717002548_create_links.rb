class CreateLinks < ActiveRecord::Migration[7.0]
  def change
    create_table :links do |t|
      t.integer :link_type
      t.references :from_page, null: false, foreign_key: { to_table: :pages }
      t.references :to_page, null: false, foreign_key: { to_table: :pages }

      t.timestamps
    end
  end
end

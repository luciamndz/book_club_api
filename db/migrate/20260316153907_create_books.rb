class CreateBooks < ActiveRecord::Migration[8.1]
  def change
    create_table :books do |t|
      t.references :book_club, null: false, foreign_key: true
      t.string :title, null: false
      t.string :author, null: false
      t.string :genre
      t.text :synopsis
      t.string :status, null: false, default: "created"
      t.integer :submitted_by_id

      t.timestamps
    end

    add_index :books, :submitted_by_id
  end
end

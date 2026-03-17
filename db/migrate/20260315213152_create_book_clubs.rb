class CreateBookClubs < ActiveRecord::Migration[8.1]
  def change
    create_table :book_clubs do |t|
      t.string :name
      t.text :description
      t.string :status

      t.timestamps
    end
  end
end

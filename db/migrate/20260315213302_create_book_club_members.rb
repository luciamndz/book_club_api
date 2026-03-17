class CreateBookClubMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :book_club_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :book_club, null: false, foreign_key: true
      t.string :role

      t.timestamps
    end
  end
end

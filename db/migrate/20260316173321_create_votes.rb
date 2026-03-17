class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      t.references :voting_round, null: false, foreign_key: true
      t.integer :book_club_member_id, null: false
      t.references :book, null: false, foreign_key: true

      t.timestamps
    end

    # One vote per member per round
    add_index :votes, [:voting_round_id, :book_club_member_id], unique: true
    add_index :votes, :book_club_member_id
  end
end
class CreateVotingRounds < ActiveRecord::Migration[8.1]
  def change
    create_table :voting_rounds do |t|
      t.references :book_club, null: false, foreign_key: true
      t.integer :book_club_member_id, null: false
      t.string :status, null: false, default: "draft"
      t.datetime :starts_at
      t.datetime :ends_at
      t.integer :winner_id # Book id

      t.timestamps
    end

    add_index :voting_rounds, :book_club_member_id
    add_index :voting_rounds, :winner_id
  end
end

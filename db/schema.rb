# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_17_005128) do
  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "book_club_members", force: :cascade do |t|
    t.integer "book_club_id", null: false
    t.datetime "created_at", null: false
    t.string "role"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["book_club_id"], name: "index_book_club_members_on_book_club_id"
    t.index ["user_id"], name: "index_book_club_members_on_user_id"
  end

  create_table "book_clubs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.string "status"
    t.datetime "updated_at", null: false
  end

  create_table "books", force: :cascade do |t|
    t.string "author", null: false
    t.integer "book_club_id", null: false
    t.datetime "created_at", null: false
    t.string "genre"
    t.datetime "selected_at"
    t.string "status", default: "created", null: false
    t.integer "submitted_by_id"
    t.text "synopsis"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["book_club_id"], name: "index_books_on_book_club_id"
    t.index ["submitted_by_id"], name: "index_books_on_submitted_by_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "password_digest"
    t.datetime "updated_at", null: false
  end

  create_table "votes", force: :cascade do |t|
    t.integer "book_club_member_id", null: false
    t.integer "book_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "voting_round_id", null: false
    t.index ["book_club_member_id"], name: "index_votes_on_book_club_member_id"
    t.index ["book_id"], name: "index_votes_on_book_id"
    t.index ["voting_round_id", "book_club_member_id"], name: "index_votes_on_voting_round_id_and_book_club_member_id", unique: true
    t.index ["voting_round_id"], name: "index_votes_on_voting_round_id"
  end

  create_table "voting_rounds", force: :cascade do |t|
    t.integer "book_club_id", null: false
    t.integer "book_club_member_id", null: false
    t.datetime "created_at", null: false
    t.datetime "ends_at"
    t.datetime "starts_at"
    t.string "status", default: "draft", null: false
    t.datetime "updated_at", null: false
    t.integer "winner_id"
    t.index ["book_club_id"], name: "index_voting_rounds_on_book_club_id"
    t.index ["book_club_member_id"], name: "index_voting_rounds_on_book_club_member_id"
    t.index ["winner_id"], name: "index_voting_rounds_on_winner_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "book_club_members", "book_clubs"
  add_foreign_key "book_club_members", "users"
  add_foreign_key "books", "book_clubs"
  add_foreign_key "votes", "books"
  add_foreign_key "votes", "voting_rounds"
  add_foreign_key "voting_rounds", "book_clubs"
end

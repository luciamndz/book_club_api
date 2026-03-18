require "test_helper"

class BookClubTest < ActiveSupport::TestCase

  def setup
    @book_club = BookClub.new(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )
  end

  test "is valid with all required attributes" do
    assert @book_club.valid?
  end

  test "is invalid without a name" do
    @book_club.name = nil
    assert_not @book_club.valid?
    assert_includes @book_club.errors[:name], "can't be blank"
  end

  test "is invalid with an empty name" do
    @book_club.name = ""
    assert_not @book_club.valid?
    assert_includes @book_club.errors[:name], "can't be blank"
  end

  test "is invalid without a description" do
    @book_club.description = nil
    assert_not @book_club.valid?
    assert_includes @book_club.errors[:description], "can't be blank"
  end

  test "is invalid with an empty description" do
    @book_club.description = ""
    assert_not @book_club.valid?
    assert_includes @book_club.errors[:description], "can't be blank"
  end

  test "is valid with status active" do
    @book_club.status = "active"
    assert @book_club.valid?
  end

  test "is valid with status inactive" do
    @book_club.status = "inactive"
    assert @book_club.valid?
  end

  test "raises ArgumentError with an unknown status" do
    assert_raises ArgumentError do
      @book_club.status = "pending"
    end
  end

  test "defaults status to active when not provided" do
    club = BookClub.new(
      name:        "New Club",
      description: "A description"
      # no status provided
    )
    assert_equal "active", club.status
  end

  test "does not override status when already provided" do
    club = BookClub.new(
      name:        "New Club",
      description: "A description",
      status:      "inactive"
    )
    assert_equal "inactive", club.status
  end

  test "destroys associated book club members when destroyed" do
    @book_club.save!
    user   = User.create!(name: "Lucia", email: "lucia@test.com", password: "password123")
    member = BookClubMember.create!(user: user, book_club: @book_club, role: "admin")

    member_id = member.id
    @book_club.destroy

    assert_not BookClubMember.exists?(member_id)
  end

  test "destroys associated books when destroyed" do
    @book_club.save!
    book = Book.create!(
      title:     "Dune",
      author:    "Frank Herbert",
      book_club: @book_club,
      status:    "created"
    )

    book_id = book.id
    @book_club.destroy

    assert_not Book.exists?(book_id)
  end

  test "destroys associated voting rounds when destroyed" do
    @book_club.save!
    user   = User.create!(name: "Lucia", email: "lucia@test.com", password: "password123")
    member = BookClubMember.create!(user: user, book_club: @book_club, role: "admin")

    voting_round = VotingRound.create!(
      book_club:  @book_club,
      created_by: member,
      status:     "draft"
    )

    round_id = voting_round.id
    @book_club.destroy

    assert_not VotingRound.exists?(round_id)
  end

  test "saves to database with valid attributes" do
    assert_difference "BookClub.count", 1 do
      @book_club.save!
    end
  end

  test "does not save with invalid attributes" do
    @book_club.name = nil

    assert_no_difference "BookClub.count" do
      @book_club.save
    end
  end

end
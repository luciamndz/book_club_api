# test/services/book_club_service_test.rb

require "test_helper"

class BookClubServiceTest < ActiveSupport::TestCase

  def setup
    @user = User.create!(
      name:     "Lucia Mendoza",
      email:    "lucia@test.com",
      password: "password123"
    )
  end

  test "create returns success with valid params" do
    result = BookClubService.new(user: @user).create(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers"
    )

    assert result.success?

    assert_instance_of BookClub, result.payload

    assert_equal "Fantasy Book Club", result.payload.name
  end

  test "create saves the book club to the database" do
    assert_difference "BookClub.count", 1 do
      BookClubService.new(user: @user).create(
        name:        "Fantasy Book Club",
        description: "A club for fantasy lovers"
      )
    end
  end

  test "create makes the creator an admin" do
    result = BookClubService.new(user: @user).create(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers"
    )

    club = result.payload

    membership = BookClubMember.find_by(user: @user, book_club: club)

    assert_not_nil membership

    assert membership.role_admin?
  end

  test "create creates exactly one membership" do
    assert_difference "BookClubMember.count", 1 do
      BookClubService.new(user: @user).create(
        name:        "Fantasy Book Club",
        description: "A club for fantasy lovers"
      )
    end
  end

  test "create returns failure without a name" do
    result = BookClubService.new(user: @user).create(
      name:        "",
      description: "A club for fantasy lovers"
    )

    assert_not result.success?
    assert result.failure?

    assert_not_nil result.errors
    assert_includes result.errors, "Name"
  end

  test "create returns failure without a description" do
    result = BookClubService.new(user: @user).create(
      name:        "Fantasy Book Club",
      description: ""
    )

    assert_not result.success?
    assert_includes result.errors, "Description"
  end

  test "create does not create membership if club fails to save" do
    assert_no_difference "BookClubMember.count" do
      BookClubService.new(user: @user).create(
        name:        "",   # invalid
        description: ""    # invalid
      )
    end
  end

  test "show returns success for a club member" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )
    BookClubMember.create!(
      user:      @user,
      book_club: book_club,
      role:      "member"
    )

    result = BookClubService.new(user: @user, book_club: book_club).show

    assert result.success?
  end

  test "show returns failure for a non-member" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )

    result = BookClubService.new(user: @user, book_club: book_club).show

    assert_not result.success?
    assert_includes result.errors, "not a member"
  end

  test "join returns success for a non-member" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )

    result = BookClubService.new(user: @user, book_club: book_club).join

    assert result.success?
  end

  test "join creates a membership record in the database" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )

    assert_difference "BookClubMember.count", 1 do
      BookClubService.new(user: @user, book_club: book_club).join
    end
  end

  test "join makes the user a member not an admin" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )

    result = BookClubService.new(user: @user, book_club: book_club).join

    assert result.payload.role_member?
    assert_not result.payload.role_admin?
  end

  test "join returns failure if user is already a member" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )
    BookClubMember.create!(
      user:      @user,
      book_club: book_club,
      role:      "member"
    )

    result = BookClubService.new(user: @user, book_club: book_club).join

    assert_not result.success?
    assert_includes result.errors, "already a member"
  end

  test "join does not create a duplicate membership" do
    book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )
    BookClubMember.create!(
      user:      @user,
      book_club: book_club,
      role:      "member"
    )

    assert_no_difference "BookClubMember.count" do
      BookClubService.new(user: @user, book_club: book_club).join
    end
  end
end
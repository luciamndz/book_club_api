require "test_helper"

class BookClubsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user  = User.create!(
      name:     "Lucia Mendoza",
      email:    "lucia@test.com",
      password: "password123"
    )
    @token = JwtService.encode(user_id: @user.id)
    @other_user  = User.create!(
      name:     "Ana Ramirez",
      email:    "ana@test.com",
      password: "password123"
    )
    @other_token = JwtService.encode(user_id: @other_user.id)

    @book_club = BookClub.create!(
      name:        "Fantasy Book Club",
      description: "A club for fantasy lovers",
      status:      "active"
    )
  end


  test "GET /book_clubs returns all clubs" do
    BookClub.create!(
      name:        "Mystery Club",
      description: "A mystery club",
      status:      "active"
    )

    get "/book_clubs",
        headers: { "Authorization" => "Bearer #{@token}" }

    body = JSON.parse(response.body)

    assert_equal 2, body.length
  end

  test "GET /book_clubs includes current_user_role in each club" do
    BookClubMember.create!(
      user:      @user,
      book_club: @book_club,
      role:      "admin"
    )

    get "/book_clubs",
        headers: { "Authorization" => "Bearer #{@token}" }

    body        = JSON.parse(response.body)
    first_club  = body.first

    assert first_club.key?("current_user_role")
    assert_equal "admin", first_club["current_user_role"]
  end

  test "GET /book_clubs returns nil current_user_role for clubs user has not joined" do

    get "/book_clubs",
        headers: { "Authorization" => "Bearer #{@token}" }

    body       = JSON.parse(response.body)
    first_club = body.first

    assert_nil first_club["current_user_role"]
  end

  test "GET /book_clubs/:id returns 200 for a member" do
    BookClubMember.create!(
      user:      @user,
      book_club: @book_club,
      role:      "member"
    )

    get "/book_clubs/#{@book_club.id}",
        headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :ok
  end


  test "GET /book_clubs/:id returns 404 for a non-existent club" do
    get "/book_clubs/999999",
        headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :not_found
  end

  test "GET /book_clubs/:id response includes members list" do
    BookClubMember.create!(
      user:      @user,
      book_club: @book_club,
      role:      "admin"
    )

    get "/book_clubs/#{@book_club.id}",
        headers: { "Authorization" => "Bearer #{@token}" }

    body = JSON.parse(response.body)

    assert body.key?("book_club")
    assert body.key?("members")
    assert_instance_of Array, body["members"]
  end

  test "POST /book_clubs returns 201 with valid params" do
    post "/book_clubs",
         params:  { book_club: { name: "New Club", description: "A new club" } },
         headers: { "Authorization" => "Bearer #{@token}" },
         as:      :json

    assert_response :created
    # :created = 201
  end

  test "POST /book_clubs creates a book club in the database" do
    assert_difference "BookClub.count", 1 do
      post "/book_clubs",
           params:  { book_club: { name: "New Club", description: "A new club" } },
           headers: { "Authorization" => "Bearer #{@token}" },
           as:      :json
    end
  end

  test "POST /book_clubs makes the creator an admin" do
    post "/book_clubs",
         params:  { book_club: { name: "New Club", description: "A new club" } },
         headers: { "Authorization" => "Bearer #{@token}" },
         as:      :json

    club       = BookClub.last
    membership = BookClubMember.find_by(user: @user, book_club: club)

    assert_not_nil membership
    assert membership.role_admin?
  end

  test "POST /book_clubs returns 422 with invalid params" do
    post "/book_clubs",
         params:  { book_club: { name: "", description: "" } },
         headers: { "Authorization" => "Bearer #{@token}" },
         as:      :json

    assert_response :unprocessable_entity
  end

  test "POST /book_clubs does not create a club with missing name" do
    assert_no_difference "BookClub.count" do
      post "/book_clubs",
           params:  { book_club: { name: "", description: "A description" } },
           headers: { "Authorization" => "Bearer #{@token}" },
           as:      :json
    end
  end

  test "POST /book_clubs/:id/join creates a membership" do
    assert_difference "BookClubMember.count", 1 do
      post "/book_clubs/#{@book_club.id}/join",
           headers: { "Authorization" => "Bearer #{@token}" }
    end
  end

  test "POST /book_clubs/:id/join makes the user a member not an admin" do
    post "/book_clubs/#{@book_club.id}/join",
         headers: { "Authorization" => "Bearer #{@token}" }

    membership = BookClubMember.find_by(user: @user, book_club: @book_club)

    assert membership.role_member?
    assert_not membership.role_admin?
  end

  test "POST /book_clubs/:id/join returns 422 if already a member" do
    BookClubMember.create!(
      user:      @user,
      book_club: @book_club,
      role:      "member"
    )

    post "/book_clubs/#{@book_club.id}/join",
         headers: { "Authorization" => "Bearer #{@token}" }

    assert_response :unprocessable_entity
  end
end
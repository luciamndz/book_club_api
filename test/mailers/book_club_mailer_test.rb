require "test_helper"

class BookClubMailerTest < ActionMailer::TestCase
  test "voting_results" do
    mail = BookClubMailer.voting_results
    assert_equal "Voting results", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end

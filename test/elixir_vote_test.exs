defmodule ElixirVoteTest do
  use ExUnit.Case
  doctest ElixirVote

  alias ElixirVote.{Topic, VotingServer}

  describe "Topic" do
    test "creates a new topic with options" do
      topic = Topic.new("Test Topic", ["Option A", "Option B"])
      
      assert topic.title == "Test Topic"
      assert topic.options == ["Option A", "Option B"]
      assert topic.total_votes == 0
      assert topic.votes == %{"Option A" => 0, "Option B" => 0}
    end

    test "adds a vote to valid option" do
      topic = Topic.new("Test", ["A", "B"])
      updated_topic = Topic.add_vote(topic, "A")
      
      assert updated_topic.total_votes == 1
      assert updated_topic.votes["A"] == 1
      assert updated_topic.votes["B"] == 0
    end

    test "returns error for invalid option" do
      topic = Topic.new("Test", ["A", "B"])
      result = Topic.add_vote(topic, "C")
      
      assert result == {:error, :invalid_option}
    end

    test "get_results returns formatted results" do
      topic = Topic.new("Test", ["A", "B"])
      |> Topic.add_vote("A")
      |> Topic.add_vote("A")
      |> Topic.add_vote("B")

      results = Topic.get_results(topic)
      
      assert results.title == "Test"
      assert results.total_votes == 3
      assert length(results.results) == 2
      
      option_a_result = Enum.find(results.results, &(&1.option == "A"))
      assert option_a_result.votes == 2
      assert option_a_result.percentage == 66.7
    end
  end

  describe "VotingServer" do
    test "starts with topic and accepts votes" do
      topic = Topic.new("Server Test", ["X", "Y"])
      {:ok, pid} = VotingServer.start_link(topic)
      
      {:ok, results} = VotingServer.vote(pid, "X")
      assert results.total_votes == 1
    end

    test "prevents duplicate votes from same voter" do
      topic = Topic.new("Duplicate Test", ["X", "Y"])
      {:ok, pid} = VotingServer.start_link(topic)
      
      {:ok, _} = VotingServer.vote(pid, "X", "voter1")
      {:error, :already_voted} = VotingServer.vote(pid, "Y", "voter1")
    end

    test "rejects votes for invalid options" do
      topic = Topic.new("Invalid Test", ["X", "Y"])
      {:ok, pid} = VotingServer.start_link(topic)
      
      {:error, :invalid_option} = VotingServer.vote(pid, "Z")
    end

    test "returns current results" do
      topic = Topic.new("Results Test", ["X", "Y"])
      {:ok, pid} = VotingServer.start_link(topic)
      
      VotingServer.vote(pid, "X")
      VotingServer.vote(pid, "X")
      
      results = VotingServer.get_results(pid)
      assert results.total_votes == 2
    end
  end
end

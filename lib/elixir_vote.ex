defmodule ElixirVote do
  @moduledoc """
  A simple voting application for the Elixir Meetup Global celebration in CDMX.
  
  This application demonstrates real-time voting capabilities using Elixir/OTP.
  """

  alias ElixirVote.VotingServer
  alias ElixirVote.Topic

  @doc """
  Start a new voting topic.
  
  ## Examples
  
      iex> {:ok, pid} = ElixirVote.start_topic("Best Elixir Feature", ["Pattern Matching", "Actor Model", "Fault Tolerance"])
      iex> is_pid(pid)
      true
  """
  def start_topic(title, options) do
    VotingServer.start_link(%Topic{title: title, options: options})
  end

  @doc """
  Cast a vote for an option in a topic.
  """
  def vote(pid, option, voter_id \\ nil) do
    VotingServer.vote(pid, option, voter_id)
  end

  @doc """
  Get current results for a topic.
  """
  def get_results(pid) do
    VotingServer.get_results(pid)
  end

  @doc """
  Get topic information.
  """
  def get_topic(pid) do
    VotingServer.get_topic(pid)
  end
end

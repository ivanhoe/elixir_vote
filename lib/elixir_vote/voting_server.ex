defmodule ElixirVote.VotingServer do
  @moduledoc """
  A GenServer that manages voting for a single topic.
  
  This server handles:
  - Storing topic state
  - Processing votes
  - Tracking voter IDs to prevent duplicate votes
  - Broadcasting updates to subscribers
  """

  use GenServer

  alias ElixirVote.Topic

  # Client API

  @doc """
  Start a voting server for a topic.
  """
  def start_link(%Topic{} = topic, opts \\ []) do
    GenServer.start_link(__MODULE__, topic, opts)
  end

  @doc """
  Cast a vote for an option.
  """
  def vote(pid, option, voter_id \\ nil) do
    GenServer.call(pid, {:vote, option, voter_id})
  end

  @doc """
  Get current voting results.
  """
  def get_results(pid) do
    GenServer.call(pid, :get_results)
  end

  @doc """
  Get topic information.
  """
  def get_topic(pid) do
    GenServer.call(pid, :get_topic)
  end

  @doc """
  Subscribe to voting updates.
  """
  def subscribe(pid) do
    GenServer.call(pid, {:subscribe, self()})
  end

  # Server Implementation

  @impl true
  def init(%Topic{} = topic) do
    state = %{
      topic: topic,
      voters: MapSet.new(),
      subscribers: []
    }
    
    {:ok, state}
  end

  @impl true
  def handle_call({:vote, option, voter_id}, _from, state) do
    case can_vote?(state, voter_id) and option in state.topic.options do
      true ->
        case Topic.add_vote(state.topic, option) do
          {:error, reason} ->
            {:reply, {:error, reason}, state}
            
          updated_topic ->
            updated_voters = if voter_id, do: MapSet.put(state.voters, voter_id), else: state.voters
            
            new_state = %{state | 
              topic: updated_topic, 
              voters: updated_voters
            }
            
            # Broadcast update to subscribers
            broadcast_update(state.subscribers, updated_topic)
            
            {:reply, {:ok, Topic.get_results(updated_topic)}, new_state}
        end
        
      false ->
        reason = cond do
          voter_id && voter_id in state.voters -> :already_voted
          option not in state.topic.options -> :invalid_option
          true -> :error
        end
        
        {:reply, {:error, reason}, state}
    end
  end

  @impl true
  def handle_call(:get_results, _from, state) do
    {:reply, Topic.get_results(state.topic), state}
  end

  @impl true
  def handle_call(:get_topic, _from, state) do
    {:reply, state.topic, state}
  end

  @impl true
  def handle_call({:subscribe, subscriber_pid}, _from, state) do
    # Monitor the subscriber so we can remove them if they die
    Process.monitor(subscriber_pid)
    updated_subscribers = [subscriber_pid | state.subscribers]
    new_state = %{state | subscribers: updated_subscribers}
    
    {:reply, :ok, new_state}
  end

  @impl true
  def handle_info({:DOWN, _ref, :process, pid, _reason}, state) do
    # Remove dead subscriber
    updated_subscribers = List.delete(state.subscribers, pid)
    new_state = %{state | subscribers: updated_subscribers}
    
    {:noreply, new_state}
  end

  # Private functions

  defp can_vote?(_state, nil), do: true
  defp can_vote?(state, voter_id), do: voter_id not in state.voters

  defp broadcast_update(subscribers, topic) do
    results = Topic.get_results(topic)
    
    Enum.each(subscribers, fn subscriber ->
      send(subscriber, {:vote_update, results})
    end)
  end
end
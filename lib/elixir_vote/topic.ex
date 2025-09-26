defmodule ElixirVote.Topic do
  @moduledoc """
  Represents a voting topic with title and options.
  """

  defstruct [:title, :options, votes: %{}, total_votes: 0, created_at: nil]

  @type t :: %__MODULE__{
    title: String.t(),
    options: [String.t()],
    votes: %{String.t() => integer()},
    total_votes: non_neg_integer(),
    created_at: DateTime.t()
  }

  @doc """
  Creates a new topic with the given title and options.
  """
  def new(title, options) when is_binary(title) and is_list(options) do
    votes = Enum.reduce(options, %{}, fn option, acc -> Map.put(acc, option, 0) end)
    
    %__MODULE__{
      title: title,
      options: options,
      votes: votes,
      total_votes: 0,
      created_at: DateTime.utc_now()
    }
  end

  @doc """
  Adds a vote to an option in the topic.
  """
  def add_vote(%__MODULE__{} = topic, option) do
    if option in topic.options do
      updated_votes = Map.update!(topic.votes, option, &(&1 + 1))
      
      %{topic | 
        votes: updated_votes,
        total_votes: topic.total_votes + 1
      }
    else
      {:error, :invalid_option}
    end
  end

  @doc """
  Gets the results of the topic with percentages.
  """
  def get_results(%__MODULE__{} = topic) do
    results = Enum.map(topic.options, fn option ->
      votes = topic.votes[option]
      percentage = if topic.total_votes > 0, do: Float.round(votes / topic.total_votes * 100, 1), else: 0.0
      
      %{
        option: option,
        votes: votes,
        percentage: percentage
      }
    end)

    %{
      title: topic.title,
      total_votes: topic.total_votes,
      results: results,
      created_at: topic.created_at
    }
  end
end
defmodule ElixirVote.CLI do
  @moduledoc """
  Command line interface for the ElixirVote demo.
  """

  alias ElixirVote.{Topic, VotingServer}

  @doc """
  Starts the demo with predefined topics about Elixir and CDMX meetup.
  """
  def demo do
    IO.puts("\n🗳️  Welcome to ElixirVote - Tidewave Demo for Elixir Meetup Global CDMX! 🇲🇽\n")

    topics = [
      {
        "What's your favorite Elixir feature?",
        ["Pattern Matching", "Actor Model", "Fault Tolerance", "LiveView", "GenServers"]
      },
      {
        "Best thing about Mexico City?",
        ["Food (Tacos!)", "Culture", "People", "Architecture", "Weather"]
      },
      {
        "What would you like to see in future meetups?",
        ["LiveView workshops", "OTP deep dives", "Real-world case studies", "Open source projects", "Networking events"]
      }
    ]

    # Start voting servers for each topic
    servers = Enum.map(topics, fn {title, options} ->
      topic = Topic.new(title, options)
      {:ok, pid} = VotingServer.start_link(topic)
      {title, pid, options}
    end)

    # Interactive demo loop
    interactive_demo(servers)
  end

  @doc """
  Simulates some voting activity for demonstration.
  """
  def simulate_votes(servers) do
    IO.puts("🎬 Running simulation with some votes...\n")

    Enum.each(servers, fn {_title, pid, options} ->
      # Simulate 5-10 votes per topic
      vote_count = :rand.uniform(6) + 4
      
      Enum.each(1..vote_count, fn i ->
        option = Enum.random(options)
        voter_id = "voter_#{i}_#{:rand.uniform(1000)}"
        
        case VotingServer.vote(pid, option, voter_id) do
          {:ok, _} -> :ok
          {:error, _} -> :ok  # Ignore errors in simulation
        end
        
        # Small delay to make it feel more realistic
        Process.sleep(100)
      end)
    end)

    IO.puts("✅ Simulation complete!\n")
  end

  defp interactive_demo(servers) do
    IO.puts("Choose an action:")
    IO.puts("1. View current results")
    IO.puts("2. Cast a vote")
    IO.puts("3. Run simulation")
    IO.puts("4. Start real-time updates")
    IO.puts("5. Exit")
    IO.write("\nEnter your choice (1-5): ")

    case IO.gets("") |> String.trim() do
      "1" -> 
        show_results(servers)
        interactive_demo(servers)
        
      "2" -> 
        cast_vote(servers)
        interactive_demo(servers)
        
      "3" -> 
        simulate_votes(servers)
        interactive_demo(servers)
        
      "4" ->
        start_realtime_updates(servers)
        interactive_demo(servers)
        
      "5" -> 
        IO.puts("\n👋 Thanks for trying ElixirVote! ¡Hasta la vista!")
        
      _ -> 
        IO.puts("Invalid choice. Please try again.")
        interactive_demo(servers)
    end
  end

  defp show_results(servers) do
    IO.puts("\n📊 Current Results:")
    IO.puts(String.duplicate("=", 50))

    Enum.each(servers, fn {_title, pid, _options} ->
      results = VotingServer.get_results(pid)
      display_results(results)
    end)

    IO.puts("")
  end

  defp cast_vote(servers) do
    IO.puts("\n🗳️  Cast Your Vote:")
    
    # Show topics
    servers
    |> Enum.with_index(1)
    |> Enum.each(fn {{title, _pid, _options}, index} ->
      IO.puts("#{index}. #{title}")
    end)

    IO.write("Select topic (1-#{length(servers)}): ")
    
    case IO.gets("") |> String.trim() |> Integer.parse() do
      {topic_num, ""} when topic_num in 1..length(servers) ->
        {title, pid, options} = Enum.at(servers, topic_num - 1)
        
        IO.puts("\n📋 #{title}")
        
        options
        |> Enum.with_index(1)
        |> Enum.each(fn {option, index} ->
          IO.puts("#{index}. #{option}")
        end)

        IO.write("Select option (1-#{length(options)}): ")
        
        case IO.gets("") |> String.trim() |> Integer.parse() do
          {option_num, ""} when option_num in 1..length(options) ->
            option = Enum.at(options, option_num - 1)
            voter_id = "cli_voter_#{:rand.uniform(10000)}"
            
            case VotingServer.vote(pid, option, voter_id) do
              {:ok, results} ->
                IO.puts("\n✅ Vote recorded! Here are the updated results:")
                display_results(results)
                
              {:error, :already_voted} ->
                IO.puts("\n❌ This voter has already voted on this topic!")
                
              {:error, :invalid_option} ->
                IO.puts("\n❌ Invalid option selected!")
                
              {:error, reason} ->
                IO.puts("\n❌ Error: #{inspect(reason)}")
            end
            
          _ ->
            IO.puts("Invalid option number.")
        end
        
      _ ->
        IO.puts("Invalid topic number.")
    end
  end

  defp start_realtime_updates(servers) do
    IO.puts("\n🔄 Starting real-time updates (press any key + Enter to stop)...")
    
    # Subscribe to all servers
    Enum.each(servers, fn {_title, pid, _options} ->
      VotingServer.subscribe(pid)
    end)

    # Start the update listener
    spawn(fn -> listen_for_updates() end)
    
    # Wait for user input to stop
    IO.gets("")
    IO.puts("Real-time updates stopped.")
  end

  defp listen_for_updates do
    receive do
      {:vote_update, results} ->
        IO.puts("\n🔔 Live Update!")
        display_results(results)
        listen_for_updates()
        
    after
      30_000 -> # Timeout after 30 seconds
        IO.puts("\n⏰ Real-time update session timed out.")
    end
  end

  defp display_results(%{title: title, total_votes: total, results: results}) do
    IO.puts("\n📈 #{title}")
    IO.puts("   Total votes: #{total}")
    
    if total > 0 do
      results
      |> Enum.sort_by(& &1.votes, :desc)
      |> Enum.each(fn %{option: option, votes: votes, percentage: percentage} ->
        bar = String.duplicate("█", trunc(percentage / 5))
        IO.puts("   #{option}: #{votes} votes (#{percentage}%) #{bar}")
      end)
    else
      IO.puts("   No votes yet!")
    end
  end
end
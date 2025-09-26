#!/usr/bin/env elixir

# Demo script for ElixirVote - Tidewave Demo
# Run with: elixir demo.exs

Mix.install([])

# Since we can't load the full application in a script easily,
# let's create a simple API demonstration

IO.puts("🗳️ ElixirVote - Quick API Demo 🇲🇽")
IO.puts("=====================================")

# Let's demonstrate the core API directly
Code.compile_file("lib/elixir_vote/topic.ex")

alias ElixirVote.Topic

# Create topics
topic1 = Topic.new("Best Elixir Feature", ["Pattern Matching", "Actor Model", "Fault Tolerance"])
IO.puts("\n📝 Created topic: #{topic1.title}")

# Add some votes
topic1 = Topic.add_vote(topic1, "Pattern Matching")
topic1 = Topic.add_vote(topic1, "Pattern Matching") 
topic1 = Topic.add_vote(topic1, "Actor Model")
topic1 = Topic.add_vote(topic1, "Fault Tolerance")

# Show results
results = Topic.get_results(topic1)
IO.puts("\n📊 Results:")
IO.puts("Total votes: #{results.total_votes}")

Enum.each(results.results, fn %{option: option, votes: votes, percentage: percentage} ->
  bar = String.duplicate("█", trunc(percentage / 10))
  IO.puts("  #{option}: #{votes} votes (#{percentage}%) #{bar}")
end)

IO.puts("\n✨ This demonstrates the core Elixir/OTP concepts:")
IO.puts("   - Immutable data structures")  
IO.puts("   - Pattern matching in function definitions")
IO.puts("   - Functional data transformations")
IO.puts("\n🚀 For the full interactive demo with GenServers:")
IO.puts("   Run: iex -S mix")
IO.puts("   Then: ElixirVote.CLI.demo()")

IO.puts("\n¡Viva Elixir! 🇲🇽")
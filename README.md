# ElixirVote 🗳️

A real-time voting application built with Elixir/OTP, created as a **Tidewave demo project** for the Elixir Meetup Global celebration in Mexico City (CDMX) 🇲🇽

## About This Demo

This project demonstrates the power of Elixir and the Actor Model through a practical voting application featuring:

- **GenServer-based architecture** - Each voting topic runs as a separate process
- **Real-time updates** - Uses message passing to broadcast vote updates to subscribers
- **Fault tolerance** - OTP supervision ensures processes can recover from failures
- **Concurrent voting** - Multiple topics can accept votes simultaneously
- **Vote validation** - Prevents duplicate votes and invalid options
- **Interactive CLI** - Full-featured command-line interface for the demo

## Features

### Core Functionality
- Create voting topics with multiple options
- Cast votes with optional voter ID tracking
- Prevent duplicate votes from the same voter
- Real-time vote counting and percentage calculations
- Subscriber notifications for live updates

### Demo Topics
Pre-loaded with fun topics for the Elixir meetup:
- "What's your favorite Elixir feature?"
- "Best thing about Mexico City?"
- "What would you like to see in future meetups?"

## Quick Start

1. **Clone the repository:**
   ```bash
   git clone https://github.com/ivanhoe/elixir_vote.git
   cd elixir_vote
   ```

2. **Install dependencies:**
   ```bash
   mix deps.get
   ```

3. **Run tests:**
   ```bash
   mix test
   ```

4. **Start the interactive demo:**
   ```bash
   iex -S mix
   ```

   Then in the IEx shell:
   ```elixir
   ElixirVote.CLI.demo()
   ```

## Usage Examples

### Programmatic API

```elixir
# Create a new voting topic
{:ok, pid} = ElixirVote.start_topic("Best Programming Language", ["Elixir", "Erlang", "Go", "Rust"])

# Cast votes
{:ok, results} = ElixirVote.vote(pid, "Elixir", "voter_1")
{:ok, results} = ElixirVote.vote(pid, "Elixir", "voter_2")

# Get current results
results = ElixirVote.get_results(pid)
# => %{
#   title: "Best Programming Language",
#   total_votes: 2,
#   results: [
#     %{option: "Elixir", votes: 2, percentage: 100.0},
#     %{option: "Erlang", votes: 0, percentage: 0.0},
#     # ...
#   ]
# }

# Subscribe to real-time updates
ElixirVote.VotingServer.subscribe(pid)
# You'll receive {:vote_update, results} messages when new votes come in
```

### Interactive CLI Demo

The CLI provides several options:
1. **View current results** - See live vote counts and percentages
2. **Cast a vote** - Interactively select topics and options
3. **Run simulation** - Watch automated voting in action
4. **Start real-time updates** - See live vote updates as they happen
5. **Exit** - End the demo

## Architecture

### Core Components

- **ElixirVote.Topic** - Data structure representing a voting topic
- **ElixirVote.VotingServer** - GenServer managing votes for a single topic
- **ElixirVote.CLI** - Interactive command-line interface
- **ElixirVote** - Main API module

### Process Model

Each voting topic runs in its own GenServer process, demonstrating Elixir's lightweight process model:

```
[CLI Process]
     |
     v
[VotingServer] ←→ [Subscriber Processes]
     |
     v
[Topic State]
```

### Key OTP Concepts Demonstrated

- **GenServer** - Stateful server processes
- **Message Passing** - Communication between processes
- **Process Monitoring** - Cleanup when subscribers die
- **Fault Isolation** - Each topic is independent
- **Concurrent Processing** - Multiple topics run simultaneously

## Testing

Run the comprehensive test suite:

```bash
mix test
```

The tests cover:
- Topic creation and vote counting
- VotingServer GenServer behavior  
- Vote validation and error handling
- Real-time update broadcasting
- Edge cases and error conditions

## Demo Script for Presentations

Perfect for demonstrating Elixir concepts at meetups:

1. Show the code structure and OTP principles
2. Run `ElixirVote.CLI.demo()` 
3. Demonstrate real-time voting
4. Show the simulation feature
5. Discuss the process model and fault tolerance
6. Open IEx and show the direct API usage

## What Makes This "Tidewave"?

This demo showcases several advanced Elixir concepts:

- **Process-per-entity model** (one GenServer per voting topic)
- **Real-time communication** via message passing
- **Fault tolerance** through process isolation
- **Concurrent processing** of multiple voting topics
- **State management** with GenServer
- **Pub/Sub patterns** with process subscribers

## Contributing

This is a demo project, but feel free to:
- Add new voting topics
- Improve the CLI interface
- Add web interface with Phoenix LiveView
- Enhance the real-time features
- Add persistence with ETS or database

## License

MIT License - Perfect for learning and experimentation!

---

**¡Viva Elixir! ¡Viva México! 🇲🇽✨**

*Created with ❤️ for the Elixir community by the power of the Actor Model*


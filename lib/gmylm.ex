defmodule Gmylm do
  @moduledoc """
  Documentation for GMYLM.
  """

  alias Gmylm.Player
  alias Gmylm.World
  alias Gmylm.World.Location
  alias Gmylm.World.Object
  alias Gmylm.World.Event
  alias Gmylm.Interface

  @doc """
  Returns a player and a world struct in their initial state
  """

  def initialize_game do
    {:ok, Player.initialize_player, World.initialize_world}
  end

  # Responsibilities
  # - receive input from user
  # - delegate to Interface.controls
  # - invoke the returned function
  def process_command(input, %Player{} = player, %World{} = world) do
    # do you want to check if valid first here?
    # IO.puts "DEBUG: Input was #{input}"
    # Interface.controls(input, player, world).()
    case Interface.controls(input, player, world) do
      {module, func_name, args} -> Kernel.apply(module, func_name, args)
      {:error} -> handle_command_error({:error}, player, world)
    end
  end

  defp handle_command_error({:error}, %Player{} = player, %World{} = world) do
    IO.puts("That's not something you can do")
    {:ok, player, world}
  end

  # ASSUMPTION: I don't think we're going to need a case where
  # the event is run and then a seperate description is output

  # What happens when you pick up an object?
  # Gets added to player's inventory
  # Gets removed from current location
  

  # What should the game loop do?
  # Run an event if there is one
  # Show a description (of the event or location)
  # Get input from player if not passed in take input 
  # Fetch the corresponding command for the player input
  # Run that command
  # Return the new game state
  # Pass that state into a new game loop call if not incrementally called

  # We should maybe have just one function here. Maybe also break down this loop into a pipe chain

  # this one is for a game loop call without an event


  # what would we call a recurse game loop function
    # game_turn 
    # render_new_game_state

  # this implementation has unhandled cases  


  def get_input_if_not_provided(input) do
    case input do
      nil  -> IO.gets "> "
      _    -> input
    end  
  end  

  def game_loop(input \\ nil, event \\ nil, incremental \\ false, %Player{} = player, %World{} = world) do
    # BEAUTIFUL PIPE CHAIN
    Interface.render_output({:ok, player, world})
    input = get_input_if_not_provided(input)
    # IO.puts "DEBUG GAME LOOP, INPUT IS: #{input}"

    case event do
       _        -> event
    end

    {_, updated_player, updated_world} = process_command(input, player, world)

    case incremental do
      false -> game_loop(updated_player, updated_world)
      true  -> {updated_player, updated_world}
    end
  end

  def start_game do
    {_status, player, world} = Gmylm.initialize_game
    Enum.find(world.events, fn(event) -> event.name == "Start Game" end) |>
    Gmylm.Interface.render_event
    game_loop(player, world)
  end
end

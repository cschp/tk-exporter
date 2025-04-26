defmodule TkExporter.CLI do
  @moduledoc """
  Command Line Interface for TkExporter
  """

  def main(_args) do
    IO.puts("Tavern-Keeper Export Tool")
    IO.puts("=======================")
    
    user_id = IO.gets("Enter your Tavern-Keeper User ID: ") |> String.trim()
    cookie = IO.gets("Enter your Tavern-Keeper session cookie: ") |> String.trim()
    
    IO.puts("\nStarting export...")
    TkExporter.export(user_id, cookie)
    IO.puts("\nExport completed! Check the 'exported-data' directory for your files.")
  end
end 
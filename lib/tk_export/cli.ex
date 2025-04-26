defmodule TkExport.CLI do
  @moduledoc """
  Command line interface for the Tavern-Keeper exporter.
  """

  def main(_args) do
    IO.puts("Tavern-Keeper Exporter")
    IO.puts("=====================")
    IO.puts("")

    user_id = IO.gets("Enter your Tavern-Keeper User ID: ") |> String.trim()
    cookie = IO.gets("Enter your Tavern-Keeper session cookie: ") |> String.trim()

    IO.puts("")
    IO.puts("Starting export...")
    IO.puts("")

    TkExporter.export(user_id, cookie)
  end
end 
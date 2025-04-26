defmodule TkExport.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: TkExport.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config do
    [
      base_url: "https://www.tavern-keeper.com",
      output_dir: "exported-data",
      retry_delay: 1000,
      max_retries: 3,
      sleep_delay: 1000
    ]
  end
end 
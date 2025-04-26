defmodule TkExporter.Application do
  use Application

  def start(_type, _args) do
    children = []
    opts = [strategy: :one_for_one, name: TkExporter.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config do
    [
      base_url: "https://www.tavern-keeper.com",
      sleep_delay: 500,
      max_retries: 3,
      retry_delay: 1000,
      output_dir: "exported-data",
      parallel_requests: 3
    ]
  end
end 
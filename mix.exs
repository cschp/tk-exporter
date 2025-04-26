defmodule TkExport.MixProject do
  use Mix.Project

  def project do
    [
      app: :tk_exporter,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "A tool to export data from Tavern-Keeper",
      package: [
        maintainers: ["Your Name"],
        licenses: ["MIT"],
        links: %{"GitHub" => "https://github.com/cschp/tk-exporter"}
      ],
      escript: [main_module: TkExport.CLI]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TkExport.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:jason, "~> 1.4"},
      {:progress_bar, "~> 3.0"},
      {:retry, "~> 0.18"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end

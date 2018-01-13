defmodule Shoutcast.Mixfile do
  use Mix.Project

  def project do
    [
      app: :shoutcast,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      package: package(),
      description: description(),
      deps: deps(),
      source_url: "https://github.com/ryanwinchester/shoutcast_ex",
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:hackney, "~> 1.10"},
    ]
  end

  defp description do
    "Shoutcast meta data"
  end

  defp package do
    [
      maintainers: ["Ryan Winchester"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/ryanwinchester/shoutcast_ex"}
    ]
  end
end

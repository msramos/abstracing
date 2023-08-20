defmodule Abstracing.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/msramos/abstracing"

  def project do
    [
      app: :abstracing,
      version: @version,
      name: "Abstracing",
      description: "A library that helps you to create OpenTelemetry spans with the least effort",
      source_url: @source_url,
      homepage_url: @source_url,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp docs do
    [
      main: "Abstracing",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/abstracing",
      extras: [
        "README.md",
        "CHANGELOG.md": [filename: "changelog", title: "Changelog"],
        LICENSE: [filename: "license", title: "License"]
      ]
    ]
  end

  defp package do
    [
      name: "abstracing",
      maintainers: ["Marcos Ramos"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:opentelemetry_api, "~> 1.2"},
      {:opentelemetry_exporter, "~> 1.2"},

      # dev and test
      {:sobelow, "~> 0.12", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false}
    ]
  end
end

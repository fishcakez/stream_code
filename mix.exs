defmodule StreamCode.Mixfile do
  use Mix.Project

  def project do
    [
      app: :stream_code,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    []
  end

  defp deps do
    [{:stream_data, ">= 0.0.0"}]
  end
end

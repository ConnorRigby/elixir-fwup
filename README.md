# Fwup

[![CircleCI](https://circleci.com/gh/ConnorRigby/elixir-fwup.svg?style=svg)](https://circleci.com/gh/ConnorRigby/elixir-fwup)
[![Hex version](https://img.shields.io/hexpm/v/fwup.svg "Hex version")](https://hex.pm/packages/fwup)

Simple Elixir wrapper around [FWUP](https://github.com/fhunleth/fwup)

## Usage

```elixir
iex()> fw = "/path/to/fwup_file.fw"
iex()> [[dev, _size]] = Fwup.devices()
iex()> args = ["-a", "-t", "complete", "-d", dev]
iex()> {:ok, fwup} = Fwup.stream(self(), args)
iex()> File.stream!(fw, [:bytes], 4096)
iex..>  |> Stream.map(fn chunk ->
iex..>    Fwup.send_chunk(fwup, chunk)
iex..>  end)
iex..>  |> Stream.run()
iex()> flush()
{:progress, 0}
{:progress, 1}
# many more
{:progess, 100}
{:ok, 0, ""}
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `fwup` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:fwup, "~> 0.3.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/fwup](https://hexdocs.pm/fwup).


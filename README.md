# ExFwup

Simple Elixir wrapper around [FWUP](https://github.com/fhunleth/fwup)

## Usage

```elixir
iex()> fw = "/path/to/fwup_file.fw"
iex()> [[dev, _size]] = ExFwup.devices()
iex()> args = ["-a", "-t", "complete", "-d", dev]
iex()> {:ok, fwup} = ExFwup.stream(self(), args)
iex()> File.stream!(fw, [:bytes], 4096)
iex..>  |> Stream.map(fn chunk ->
iex..>    ExFwup.send_chunk(fwup, chunk)
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
by adding `ex_fwup` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:ex_fwup, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_fwup](https://hexdocs.pm/ex_fwup).


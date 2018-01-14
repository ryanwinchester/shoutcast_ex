# Shoutcast

[https://hexdocs.pm/shoutcast](https://hexdocs.pm/shoutcast)

Read meta data from a shoutcast stream.

## Installation

in `mix.exs`

```elixir
def deps do
  [
    {:shoutcast, "~> 0.1.0"}
  ]
end
```

## Usage

```elixir
iex> Shoutcast.read_meta("http://ice1.somafm.com/lush-128-mp3")
{:ok, %Meta{}}
```

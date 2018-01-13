defmodule Shoutcast do

  defmodule Meta do
    defstruct [:offset, :length, :data, :raw]
    @type t :: %__MODULE__{data: map, offset: integer, length: integer, raw: binary}
  end

  @doc """
  Get the meta data from a shoutcast stream.

  ## Example:

      iex> Shoutcast.read_meta("http://ice1.somafm.com/lush-128-mp3")
      {:ok, %Meta{}}

  """
  @spec read_meta(binary) :: {:ok, Meta.t}
  def read_meta(url) do
    {:ok, _status, headers, ref} = :hackney.get(url, [{'Icy-Metadata', '1'}], "", [])

    offset =
      headers
      |> Enum.into(%{})
      |> Map.get("icy-metaint")
      |> String.to_integer()

    {:ok, data} = read_body(offset + 4081, ref, <<>>)

    extract_meta(data, offset)
  end

  defp read_body(max_length, ref, acc) when max_length > byte_size(acc) do
    case :hackney.stream_body(ref) do
      {:ok, data}      -> read_body(max_length, ref, <<acc::binary, data::binary>>)
      :done            -> {:ok, acc}
      {:error, reason} -> {:error, reason}
    end
  end

  defp read_body(_, _, acc), do: {:ok, acc}

  defp extract_meta(data, offset) do
    << _::binary-size(offset), length::binary-size(1), chunk::binary >> = data

    # The `length` byte will equal the metadata length/16.
    # Multiply by 16 to get the actual metadata length.
    <<l>> = length
    meta_length = l * 16

    << meta::binary-size(meta_length), _::binary >> = chunk

    {:ok, %Meta{offset: offset, length: meta_length, raw: meta, data: process_meta(meta)}}
  end

  defp process_meta(meta) do
    meta
    |> String.trim_trailing(<<0>>)
    |> String.split(";")
    |> Enum.map(&String.split(&1, "="))
    |> Enum.reject(&(&1 == [""]))
    |> Enum.map(fn [k, v] -> {k, String.trim(v, "'")} end)
    |> Enum.into(%{})
  end
end

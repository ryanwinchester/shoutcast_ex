defmodule Shoutcast do

  defmodule Meta do
    defstruct [:offset, :length, :data, :raw, :string]
    @type t :: %__MODULE__{
      data: map,
      offset: integer,
      length: integer,
      raw: binary,
      string: String.t
    }
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

    offset = get_offset(headers)

    {:ok, data} = read_body(offset + 4081, ref, <<>>)

    {meta_length, meta} = extract_meta(data, offset)

    {:ok,
      %Meta{
        data: process_meta(meta),
        offset: offset,
        length: meta_length,
        raw: meta,
        string: String.trim(meta, <<0>>)
      }
    }
  end

  # Stream the body until we get what we want.
  defp read_body(max_length, ref, acc) when max_length > byte_size(acc) do
    case :hackney.stream_body(ref) do
      {:ok, data}      -> read_body(max_length, ref, <<acc::binary, data::binary>>)
      :done            -> {:ok, acc}
      {:error, reason} -> {:error, reason}
    end
  end

  defp read_body(_, _, acc), do: {:ok, acc}

  # Get the byte offset from the `icy-metaint` header.
  defp get_offset(headers) do
    headers
    |> Enum.into(%{})
    |> Map.get("icy-metaint")
    |> String.to_integer()
  end

  # Extract the meta data from the binary file stream.
  defp extract_meta(data, offset) do
    << _::binary-size(offset), length::binary-size(1), chunk::binary >> = data

    # The `length` byte will equal the metadata length/16.
    # Multiply by 16 to get the actual metadata length.
    <<l>> = length
    meta_length = l * 16

    << meta::binary-size(meta_length), _::binary >> = chunk

    {meta_length, meta}
  end

  # Process the binary meta data into a map.
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

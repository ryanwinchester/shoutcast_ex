defmodule Mix.Tasks.Read.Meta do
  use Mix.Task

  @shortdoc "Read the meta data from a stream"

  def run(url) do
    Mix.Task.run "app.start"

    {:ok, meta} = Shoutcast.read_meta(url)

    Enum.each meta.data, fn
      {k, ""} -> IO.puts "#{k}: (n/a)"
      {k, v}  -> IO.puts "#{k}: #{v}"
    end
  end
end

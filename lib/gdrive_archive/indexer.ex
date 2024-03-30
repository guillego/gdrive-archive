defmodule GdriveArchive.Indexer do
  @batch_size 20

  alias GdriveArchive.Gdrive
  alias GdriveArchive.Repo
  alias GdriveArchive.File

  def execute() do
    Gdrive.stream_all_files()
    |> Stream.chunk_every(@batch_size)
    |> Stream.map(&save_batch_of_files/1)
    |> Stream.run()
  end

  defp save_batch_of_files(files) do
    Repo.insert_all(File, files)
  end
end

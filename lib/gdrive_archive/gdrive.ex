defmodule GdriveArchive.Gdrive do
  alias GoogleApi.Drive.V3.Connection
  alias GoogleApi.Drive.V3.Api.Files
  require Logger

  def list_all_files do
    stream_file_list()
    |> Stream.map(&Map.take(&1, [:id, :mimeType, :parents, :md5Checksum, :size, :name]))
    |> Stream.each(fn file -> IO.puts("File: #{inspect(file)}") end)
    |> Stream.run()
  end

  def stream_file_list do
    {:ok, %{token: token}} = Goth.Token.for_scope("https://www.googleapis.com/auth/drive")
    Logger.info("Token: #{inspect(token)}")
    conn = Connection.new(token)

    Stream.resource(
      # Initial state
      fn -> {conn, nil} end,
      fn
        {conn, nil} ->
          fetch_and_return_next_page(conn, [])

        {conn, ""} ->
          {:halt, nil}

        {conn, page_token} ->
          fetch_and_return_next_page(conn, page_token)
      end,
      fn _ -> nil end
    )
  end

  defp fetch_and_return_next_page(conn, page_token) do
    options = [
      includeItemsFromAllDrives: true,
      supportsAllDrives: true,
      corpora: "allDrives",
      fields: "nextPageToken, files(id, mimeType, size, md5Checksum, parents, name)",
      pageToken: page_token
    ]

    case Files.drive_files_list(conn, options) do
      {:ok, %{nextPageToken: "", files: files}} ->
        # No more pages
        {files, {conn, nil}}

      {:ok, %{nextPageToken: next_page_token, files: files}} ->
        # There are more pages
        {files, {conn, next_page_token}}

      {:error, _} = error ->
        Logger.error("Failed to fetch files: #{inspect(error)}")
        # Return empty list and halt if there's an error
        {[], nil}
    end
  end
end

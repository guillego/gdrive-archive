defmodule GdriveArchive.Gdrive do
  alias GoogleApi.Drive.V3.Connection
  alias GoogleApi.Drive.V3.Api.Files
  require Logger

  @default_file %{
    parent: nil,
    mime_type: nil,
    size: nil,
    checksum: nil,
    name: nil,
    id: nil
  }

  def list_all_files do
    stream_file_list()
    |> Stream.map(&normalize_map(&1))
    |> Stream.each(fn file -> IO.puts("File: #{inspect(file)}") end)
    |> Stream.run()
  end

  def stream_all_files do
    stream_file_list()
    |> Stream.map(&normalize_map(&1))
  end

  defp normalize_map(map) do
    map
    |> Map.take([:id, :mimeType, :parents, :md5Checksum, :size, :name])
    |> Enum.reduce(@default_file, fn {key, value}, acc ->
      case key do
        :mimeType ->
          Map.put(acc, :mime_type, value)

        :md5Checksum ->
          Map.put(acc, :checksum, value)

        :parents ->
          if value != nil,
            do: Map.put(acc, :parent, Enum.at(value, 0)),
            else: Map.put(acc, :parent, nil)

        :size ->
          if value != nil,
            do: Map.put(acc, :size, String.to_integer(value)),
            else: Map.put(acc, :parent, nil)

        _ ->
          Map.put(acc, key, value)
      end
    end)
  end

  def stream_file_list do
    Stream.resource(
      # Initial state no connection, no page token, fetch new token
      fn -> {:no_conn, nil, gdrive_authorization!()} end,
      fn
        # Initial fetch or after fetching all pages
        {:no_conn, nil, token} ->
          conn = Connection.new(token)
          fetch_and_return_next_page(conn, [], token)

        # Halt condition
        {_conn, :halt, _token} ->
          {:halt, nil}

        # Fetch next page
        {conn, page_token, token} ->
          fetch_and_return_next_page(conn, page_token, token)
      end,
      fn _ -> nil end
    )
  end

  defp gdrive_authorization!() do
    {:ok, goth_token} = Goth.fetch(GdriveArchive.Goth)
    goth_token.token
  end

  defp fetch_and_return_next_page(conn, page_token, token) do
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
        {files, {:no_conn, nil, token}}

      {:ok, %{nextPageToken: next_page_token, files: files}} ->
        # There are more pages
        {files, {conn, next_page_token, token}}

      {:error, %Tesla.Env{status: 401, body: body}} = error ->
        if token_expired?(body) do
          # Token has expired, refresh it and retry fetching the current page
          new_token = gdrive_authorization!()
          new_conn = Connection.new(new_token)
          fetch_and_return_next_page(new_conn, page_token, new_token)
        else
          Logger.error("Failed to fetch files: #{inspect(error)}")
          {:halt, {conn, :halt, token}}
        end

      {:error, _} = error ->
        # Log other errors and halt the stream
        Logger.error("Failed to fetch files: #{inspect(error)}")
        {:halt, {conn, :halt, token}}
    end
  end

  defp token_expired?(error_body) do
    case Jason.decode(error_body) do
      # Parse the JSON response body successfully
      {:ok, %{"error" => %{"details" => details}}} ->
        # Check if any of the details contain an "ACCESS_TOKEN_EXPIRED" reason
        Enum.any?(details, fn detail ->
          detail["@type"] == "type.googleapis.com/google.rpc.ErrorInfo" and
            detail["reason"] == "ACCESS_TOKEN_EXPIRED"
        end)

      # Parsing failed or the error body doesn't match the expected structure
      _ ->
        false
    end
  end
end

defmodule GdriveArchive.Queries do
  alias Ecto.Adapters.SQL

  def get_all_children(node_id) do
    query = """
    WITH RECURSIVE descendant_files AS (
      SELECT *
      FROM files
      WHERE id = '#{node_id}'

      UNION ALL

      SELECT f.*
      FROM files f
      JOIN descendant_files df ON df.id = f.parent
    )
    SELECT *
    FROM descendant_files;
    """

    {:ok, result} = SQL.query(GdriveArchive.Repo, query, [])

    result
    |> Map.get(:rows)
    |> Enum.map(fn [id, parent, name, mime_type, size, checksum] ->
      %{
        id: id,
        parent: parent,
        name: name,
        mime_type: mime_type,
        size: size,
        checksum: checksum,
        # Prepare for tree structure
        children: []
      }
    end)
  end
end

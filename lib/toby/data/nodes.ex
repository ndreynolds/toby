defmodule Toby.Data.Nodes do
  @moduledoc false

  def visible do
    case :net_adm.names() do
      {:ok, visible} -> visible
      {:error, _} -> []
    end
  end

  def connected do
    Node.list()
  end
end

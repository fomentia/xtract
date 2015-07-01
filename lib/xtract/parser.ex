defmodule Xtract.Parser do
  require Record
  require Logger
  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  @doc """
    Xtract.Parser should take an XML document and xtract it (haha) into an Elixir datastructure.
  """

  def parse(xml) do
    node_names = Regex.run(~r/[^<][^>]*/, xml)
    top_node_name = List.first(node_names)
    top_node_name_bitstring = String.to_char_list("/#{top_node_name}")

    {doc, _} = xml |> :erlang.bitstring_to_list |> :xmerl_scan.string
    elements = :xmerl_xpath.string(top_node_name_bitstring, doc)
    
    nodes = Enum.map(elements, fn(elem) ->
      represent(xmlElement(elem, :content))
    end)

    nodes
  end

  defp represent(node) do
    cond do
      Record.is_record(node, :xmlElement) ->
        name = xmlElement(node, :name)
        content = xmlElement(node, :content)
        Map.put(%{}, name, represent(content))

      Record.is_record(node, :xmlText) ->
        xmlText(node, :value) |> to_string

      is_list(node) ->
        case Enum.map(node, &(represent(&1))) do
          [text_content] when is_binary(text_content) ->
            text_content

          elements ->
            Enum.reduce(elements, %{}, fn(x, acc) ->
              if is_map(x) do
                Map.merge(acc, x)
              else
                acc
              end
            end)
        end

      true -> "cannot represent #{inspect node}"
    end
  end
end

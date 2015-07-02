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
    {doc, _} = xml |> :erlang.bitstring_to_list |> :xmerl_scan.string
    elements = :xmerl_xpath.string('.', doc)
    
    nodes = Enum.map(elements, fn(elem) ->
      represent(xmlElement(elem, :content))
    end)

    nodes
  end

  defp represent(node) do
    data = Map.new()

    cond do
      Record.is_record(node, :xmlElement) ->
        name = xmlElement(node, :name)
        attribute = xmlElement(node, :attributes) |> List.first |> represent_attr
        content = xmlElement(node, :content)
        Map.merge(data, Map.put(%{}, name, %{:attr => attribute, :content => represent(content)}))

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

  def represent_attr({:xmlAttribute, key, _, _, _, _, _, _, value, _}) do
    Map.put(%{}, key, value)
  end

  def represent_attr(nil) do
    "I'm sorry, but I can't parse that. Please take a look at your XML to make sure it's OK. If this is my fault, I'm sorry. :("
  end
end

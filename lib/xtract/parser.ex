defmodule Xtract.Parser do
  require Record
  require Logger

  Record.defrecord :xmlAttribute, Record.extract(:xmlAttribute, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlElement, Record.extract(:xmlElement, from_lib: "xmerl/include/xmerl.hrl")
  Record.defrecord :xmlText, Record.extract(:xmlText, from_lib: "xmerl/include/xmerl.hrl")

  @data Keyword.new()

  def parse(xml) do
    {doc, _} = xml |> :binary.bin_to_list |> :xmerl_scan.string
    elements = :xmerl_xpath.string('.', doc)

    nodes = Enum.map(elements, fn(elem) ->
      represent(xmlElement(elem, :content))
    end)

    nodes
  end

  # Node representation

  defp represent(node) when Record.is_record(node, :xmlElement) do
    name = xmlElement(node, :name)
    attribute = xmlElement(node, :attributes) |> List.first |> represent_attr
    content = xmlElement(node, :content)
    
    @data ++ Keyword.put(Keyword.new, name, [attrs: attribute, content: represent(content)])
  end

  defp represent(node) when Record.is_record(node, :xmlText) do
    xmlText(node, :value) |> to_string
  end

  defp represent(node) when is_list(node) do
    case Enum.map(node, &(represent(&1))) do
      [text_content] when is_binary(text_content) ->
        text_content

      elements ->
        Enum.reduce(elements, [], fn(x, acc) ->
          if is_list(x) do
            Keyword.merge(acc, x)
          else
            acc
          end
        end)
    end
  end

  defp represent(node) do
    "cannot represent #{inspect node}"
  end

  # Attribute representation
  
  def represent_attr({:xmlAttribute, key, _, _, _, _, _, _, value, _}) do
    Dict.put([], key, value)
  end

  def represent_attr(nil) do
    nil
  end

  # Find function

  def find(xml, request) do
    find_node = String.to_char_list("//#{request}")
    {doc, _} = xml |> :erlang.bitstring_to_list |> :xmerl_scan.string
    elements = :xmerl_xpath.string(find_node, doc)
    
    nodes = Enum.map(elements, fn(elem) ->
      represent(xmlElement(elem, :content))
    end)

    nodes
  end
end

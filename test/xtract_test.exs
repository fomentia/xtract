defmodule XtractTest do
  use ExUnit.Case

  def example_xml do
    """
    <book num="Gen">
      <chapter num="1">
        <verse num="1">In the beginning God created the heaven and the earth.</verse>
      </chapter>
    </book>  
    """
  end

  def example_xtraction do
    [ type: :book, num: "Gen", contents:
      [ type: :chapter, num: 1, contents:
        [ type: :verse, num: 1, contents: "In the beginning God created the heaven and the earth." ] ] ]
  end
  
  test "Xtract.Parser.parse/1 can xtract types" do
    xtracted_data = Xtract.Parser.parse(example_xml)
    assert xtracted_data[:type] == :book
  end

  test "Xtract.Parser.parse/1 can xtract tags" do
    xtracted_data = Xtract.Parser.parse(example_xml)
    assert xtracted_data[:num] == "Gen"
  end
end



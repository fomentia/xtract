defmodule XtractTest do
  use ExUnit.Case

  def example_xml do
    """
    <book title="Genesis">
      <content>
        <chapter>
          <number>1</number>
          <content>
            <verse>
              <number>1</number>
              <content>In the beginning God created the heaven and the earth.</content>
            </verse>
          </content>
        </chapter>
      </content>
    </book>
    """
  end
  
  test "Xtract.Parser.parse/1 can xtract values" do
    xtracted_data = Xtract.Parser.parse(example_xml)
    book = List.first(xtracted_data)
    assert book[:title] == "Genesis"
  end
end



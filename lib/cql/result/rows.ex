defmodule CQL.Result.Rows do
  import CQL.Decoder

  defstruct [
    :data,
  ]

  @ascii     0x01
  @bigint    0x02
  @blob      0x03
  @boolean   0x04
  @counter   0x05
  @decimal   0x06
  @double    0x07
  @float     0x08
  @int       0x09
  @timestamp 0x0B
  @uuid      0x0C
  @varchar   0x0D
  @varint    0x0E
  @timeuuid  0x0F
  @inet      0x10
  @list      0x20
  @map       0x21
  @set       0x22
  @udt       0x30
  @tuple     0x31


  def decode(buffer) do
    {data, buffer} = unpack buffer,
      metadata:     &CQL.MetaData.decode/1,
      rows_count:   &int/1

    {rows_content, ""} = ntimes(data.rows_count, row_content(data.metadata), buffer)

    %__MODULE__{data: rows_content}
  end

  def row_content(metadata) do
    fn binary ->
      {row, rest} = ntimes(metadata.columns_count, &bytes/1, binary)
      {parse(row, metadata.columns_specs), rest}
    end
  end

  def parse(row_content, columns_specs) do
    columns_specs
    |> Enum.map(&Map.get(&1, :type))
    |> Enum.zip(row_content)
    |> Enum.map(&CQL.DataTypes.decode/1)
  end
end

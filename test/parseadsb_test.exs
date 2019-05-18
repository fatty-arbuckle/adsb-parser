defmodule ParseTest do
  use ExUnit.Case

  test "Non-MSG type messages" do
    Enum.each([
      "SEL,,496,2286,4CA4E5,27215,2010/02/19,18:06:07.710,2010/02/19,18:06:07.710,RYR1427",
      "ID,,496,7162,405637,27928,2010/02/19,18:06:07.115,2010/02/19,18:06:07.115,EZY691A",
      "AIR,,496,5906,400F01,27931,2010/02/19,18:06:07.128,2010/02/19,18:06:07.128",
      "STA,,5,179,400AE7,10103,2008/11/28,14:58:51.153,2008/11/28,14:58:51.153,RM",
      "CLK,,496,-1,,-1,2010/02/19,18:18:19.036,2010/02/19,18:18:19.036"
    ], fn raw ->
      assert(:not_supported == Aircraft.ParseAdsb.parse(raw))
    end)
  end

  test "MSG,1" do
    rawMessage = "MSG,1,111,11111,A44728,111111,2018/11/17,21:33:06.976,2018/11/17,21:33:06.938,JBU1616 ,,,,,,,,,,,0"
    expected = %Aircraft{
      icoa:           "A44728",
      dateGenerated:  "2018/11/17",
      timeGenerated:  "21:33:06.976",
      dateLogged:     "2018/11/17",
      timeLogged:     "21:33:06.938",
      callsign:       "JBU1616"
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,2" do
    rawMessage = "MSG,2,1,1,7BD8B8,1,2019/02/23,03:07:26.701,2019/02/23,03:07:26.768,,,29,,,,,,,,,-1"
    expected = %Aircraft{
      icoa:           "7BD8B8",
      dateGenerated:  "2019/02/23",
      timeGenerated:  "03:07:26.701",
      dateLogged:     "2019/02/23",
      timeLogged:     "03:07:26.768",
      speed:       29,
      isOnGround?:    True
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,3" do
    rawMessage = "MSG,3,,,AADFF1,,,,,,,40000,,,42.49749,-71.02463,,,0,0,0,0"
    expected = %Aircraft{
      icoa:           "AADFF1",
      dateGenerated:  "",
      timeGenerated:  "",
      dateLogged:     "",
      timeLogged:     "",
      longitude:      -71.02463,
      latitude:       42.49749,
      altitude:       40000,
      alert?:         False,
      emergency?:     False,
      spi?:           False,
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,4" do
    rawMessage = "MSG,4,,,A77C11,,,,,,,,397,251,,,0,,0,0,0,0"
    expected = %Aircraft{
      icoa:           "A77C11",
      dateGenerated:  "",
      timeGenerated:  "",
      dateLogged:     "",
      timeLogged:     "",
      speed:          397,
      heading:        251,
      vertical:       0,
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,5" do
    rawMessage = "MSG,5,1,1,AA759B,1,2019/02/22,23:20:55.243,2019/02/22,23:20:55.294,,5125,,,,,,,0,,0,"
    expected = %Aircraft{
      icoa:           "AA759B",
      dateGenerated:  "2019/02/22",
      timeGenerated:  "23:20:55.243",
      dateLogged:     "2019/02/22",
      timeLogged:     "23:20:55.294",
      altitude:       5125,
      alert?:         False,
      spi?:           False,
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,6" do
    rawMessage = "MSG,6,1,1,A9BF4B,1,2019/02/22,23:25:50.990,2019/02/22,23:25:51.011,,,,,,,,3445,0,0,0,"
    expected = %Aircraft{
      icoa:           "A9BF4B",
      dateGenerated:  "2019/02/22",
      timeGenerated:  "23:25:50.990",
      dateLogged:     "2019/02/22",
      timeLogged:     "23:25:51.011",
      squawk:         3445,
      alert?:         False,
      emergency?:     False,
      spi?:           False,
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,7" do
    rawMessage = "MSG,7,1,1,A72369,1,2019/02/22,23:16:21.721,2019/02/22,23:16:21.754,,6200,,,,,,,,,,"
    expected = %Aircraft{
      icoa:           "A72369",
      dateGenerated:  "2019/02/22",
      timeGenerated:  "23:16:21.721",
      dateLogged:     "2019/02/22",
      timeLogged:     "23:16:21.754",
      altitude:       6200,
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "MSG,8" do
    rawMessage = "MSG,8,1,1,A8DEDA,1,2019/02/22,23:09:10.797,2019/02/22,23:09:10.842,,,,,,,,,,,,0"
    expected = %Aircraft{
      icoa:           "A8DEDA",
      dateGenerated:  "2019/02/22",
      timeGenerated:  "23:09:10.797",
      dateLogged:     "2019/02/22",
      timeLogged:     "23:09:10.842",
      isOnGround?:    False
    }
    assert expected == Aircraft.ParseAdsb.parse(rawMessage)
  end

  test "Unknown MSG subtype" do
    assert :unknown_msg_type == Aircraft.ParseAdsb.parse("MSG,9,,,,,,,,,,,,,,,,,,,,")
  end

  test "trim failures" do
    raw = [
      "MSG,8,1,1,A29611,1,2019/05/18,13:57:23.247,2019/05/18,13:57:23.300,,,,,,,,,,,,0",
      "MSG,3,1,1,A29611,1,2019/05/18,13:57:23.251,2019/05/18,13:57:23.301,,11725,,,42.54364,-71.56282,,,,,,0",
      "MSG,5,1,1,A11F5A,1,2019/05/18,13:57:23.260,2019/05/18,13:57:23.302,,11250,,,,,,,0,,0,",
      "MSG,7,1,1,A29611,1,2019/05/18,13:57:23.266,2019/05/18,13:57:23.302,,11725,,,,,,,,,,",
      "MSG,8,1,1,A29611,1,2019/05/18,13:57:23.313,2019/05/18,13:57:23.356,,,,,,,,,,,,0",
      "MSG,4,1,1,A29611,1,2019/05/18,13:57:23.366,2019/05/18,13:57:23.411,,,369,105,,,-1088,,,,,0",
      "MSG,4,1,1,4072F5,1,2019/05/18,13:57:23.399,2019/05/18,13:57:23.463,,,425,35,,,0,,,,,0",
      "MSG,7,1,1,A29611,1,2019/05/18,13:57:23.411,2019/05/18,13:57:23.464,,11725,,,,,,,,,,",
      "MSG,3,1,1,A11F5A,1,2019/05/18,13:57:23.411,2019/05/18,13:57:23.464,,11250,,,42.40262,-71.25867,,,,,,0",
      "MSG,7,1,1,A29611,1,2019/05/18,13:57:23.414,2019/05/18,13:57:23.465,,11725,,,,,,,,,,",
      "MSG,7,1,1,A50E47,1,2019/05/18,13:57:23.417,2019/05/18,13:57:23.465,,25025,,,,,,,,,,",
      "MSG,7,1,1,A50E47,1,2019/05/18,13:57:23.420,2019/05/18,13:57:23.465,,25025,,,,,,,,,,",
      "MSG,8,1,1,A1D9D7,1,2019/05/18,13:57:23.455,2019/05/18,13:57:23.518,,,,,,,,,,,,",
      "MSG,5,1,1,A278F3,1,2019/05/18,13:57:23.461,2019/05/18,13:57:23.519,,2775,,,,,,,0,,0,",
      "MSG,7,1,1,A278F3,1,2019/05/18,13:57:23.472,2019/05/18,13:57:23.520,,2775,,,,,,,,,,",
      "MSG,7,1,1,A11F5A,1,2019/05/18,13:57:23.485,2019/05/18,13:57:23.521,,11250,,,,,,,,,,",
      "MSG,5,1,1,A1D9D7,1,2019/05/18,13:57:23.523,2019/05/18,"
    ]
    Enum.map(raw, fn msg ->
      Aircraft.ParseAdsb.parse(msg)
    end)
  end
end

package ui;

typedef GTextStyle = {
    ?font: h2d.Font,
    ?color: h3d.Vector4,
    ?size: Int,
    ?typewrite: Bool
}

class GText extends h2d.Object {
    public static var INFO:GTextStyle;
    public static var BAD:GTextStyle;
    public static var GOOD:GTextStyle;
}
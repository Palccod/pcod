import QtQuick
import QtQuick.Svg

Item {
    id: root
    property url source
    property bool colorized: false
    property color tint: "white"
    property int avatarWidth: 200
    property real animationSpeed: 1.0
    property int fillMode: Image.Stretch
    property bool smooth: true
    property bool mipmap: true
    
    // Simple approach: Use the SVG directly and let Qt handle it
    // The SVG uses currentColor for the body fill, but Qt's SvgImage doesn't support currentColor
    // So we'll render the SVG and apply a color transform via ShaderEffect
    
    // Base SVG renderer (always present)
    SvgImage {
        id: baseSvg
        anchors.fill: parent
        source: root.source
        fillMode: root.fillMode
        smooth: root.smooth
        mipmap: root.mipmap
        visible: !root.colorized
    }
    
    // Colorized version via shader
    ShaderEffectSource {
        id: shaderSource
        visible: root.colorized
        anchors.fill: parent
        sourceItem: baseSvg
        format: ShaderEffectSource.RGBA8888
        live: true
    }
    
    ShaderEffect {
        id: colorizeShader
        visible: root.colorized
        anchors.fill: parent
        property variant source: shaderSource
        property color tintColor: root.tint
        
        fragmentShader: "
            uniform sampler2D source;
            uniform lowp vec4 tintColor;
            varying highp vec2 qt_TexCoord0;
            void main() {
                lowp vec4 tex = texture2D(source, qt_TexCoord0);
                // Detect body pixels (not white/cream eyes, not black pupils, not transparent)
                lowp float lum = dot(tex.rgb, vec3(0.299, 0.587, 0.114));
                lowp float sat = max(max(tex.r, tex.g), tex.b) - min(min(tex.r, tex.g), tex.b);
                
                // Keep eyes (high lum, low sat), pupils (low lum), transparent
                if (lum > 0.85 || lum < 0.12 || sat < 0.15 || tex.a < 0.05) {
                    gl_FragColor = tex;
                } else {
                    // Apply tint to body
                    gl_FragColor = vec4(tintColor.rgb * tex.rgb, tex.a);
                }
            }
        "
    }
}
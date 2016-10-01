varying vec4 triangleColor;
uniform sampler2D uMainTexture;

void main() {
#ifdef USE_TEXTURE
    gl_FragColor = triangleColor;
#endif
}

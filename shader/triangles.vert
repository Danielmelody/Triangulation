#define S 50.0

attribute vec3 position;
attribute vec2 aMainUV;
attribute vec2 triangleUV1;
attribute vec2 triangleUV2;
varying vec4 triangleColor;
uniform sampler2D uMainTexture;

mat3 gx = mat3(1.0, 2.0, 1.0, 0.0, 0.0, 0.0, -1.0, -2.0, -1.0 );
mat3 gy = mat3(1.0, 0.0, -1.0, 2.0, 0.0, -2.0, 1.0, 0.0, -1.0);

float getGradient(vec2 uv, float level) {
    mat3 I;
    for (float i = 0.0; i < 3.0; i++) {
		for (float j= 0.0; j<3.0; j++) {
            I[int(i)][int(j)] = length(texture2D( uMainTexture, uv + level * vec2(i, j)).rgb);
		}
    }
    float dpx3 = dot(gx[0], I[0]) + dot(gx[1], I[1]) + dot(gx[2], I[2]);
    float dpy3 = dot(gy[0], I[0]) + dot(gy[1], I[1]) + dot(gy[2], I[2]);
    float x = dpx3 * dpx3;
    float y = dpy3 * dpy3;
    return dpx3 * dpx3 + dpy3 * dpy3;
}

vec2 getCloseEdgePos(vec2 uv, float level) {
    if (uv.x < 0.01 || uv.x >0.99 || uv.y < 0.01 || uv.y > 0.99) {
        return uv;
    }
    vec2 final = uv;
    for (int i = 0; i < 1; ++i) {
        float maxl = 0.0;
        vec2 edge = vec2(0.0, 0.0);
        for (float i = 0.0; i < S; ++i) {
            for (float j = 0.0; j < S; ++j) {
                vec2 uvPos = vec2(i - S / 2.0, j - S / 2.0) * d_search;
                float l = getGradient(uvPos + final, d_edge);
                if (l > maxl) {
                    edge = uvPos;
                }
                maxl = max(l, maxl);
            }
        }
        final = edge + final;
        //level /= 3.1415;
    }
    return final ;
}

void main () {
    vec2 fixedUV = getCloseEdgePos(aMainUV, d_search);
    vec2 fixedUV1 = getCloseEdgePos(triangleUV1, d_search);
    vec2 fixedUV2 = getCloseEdgePos(triangleUV2, d_search);
    gl_Position = vec4(fixedUV * 2.0 - 1.0, 0.0, 1.0);
    // gl_Position = vec4(position, 1.0);
    triangleColor = texture2D(uMainTexture, (fixedUV + fixedUV1 + fixedUV2) / 3.0);
}

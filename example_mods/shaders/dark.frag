#pragma header

uniform float strength;

void main()
{
    vec4 color = flixel_texture2D(bitmap, openfl_TextureCoordv);

    vec3 result = color.rgb;
    float lum = dot(result, vec3(0.299, 0.587, 0.114));

    if (strength >= 0.0)
    {
        vec3 night = result;

        night = mix(vec3(lum), night, 0.25);

        night *= vec3(0.72, 0.73, 0.76);

        night *= 0.72;

        night = pow(night, vec3(1.08));

        result = mix(result, clamp(night, 0.0, 1.0), strength);
    }
    else
    {
        float s = -strength;

        vec3 warm = result;

        warm = mix(vec3(lum), warm, 1.35);

        warm *= vec3(1.08, 1.03, 0.92);

        warm = (warm - 0.5) * 1.10 + 0.5;

        warm = pow(warm, vec3(0.95));

        result = mix(result, clamp(warm, 0.0, 1.0), s);
    }

    gl_FragColor = vec4(result, color.a);
}
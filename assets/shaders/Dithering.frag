uniform vec2 iResolution;
uniform float iTime;

const float PIXEL_FACTOR = 320.; // Lower num - bigger pixels (this will be the screen width)
const float COLOR_FACTOR = 4.;   // Higher num - higher colors quality

const mat4 ditherTable = mat4(
    -4.0, 0.0, -3.0, 1.0,
    2.0, -2.0, 3.0, -1.0,
    -3.0, 1.0, -4.0, 0.0,
    3.0, -1.0, 2.0, -2.0
);

void main()
{          
    vec2 fragCoord = openfl_TextureCoordv * iResolution;        
    // Reduce pixels            
    vec2 size = PIXEL_FACTOR * iResolution.xy/iResolution.x;
    vec2 coor = floor( fragCoord/iResolution.xy * size) ;
    vec2 uv = coor / size;   
                
   	// Get source color
    vec3 col = texture(iChannel0, uv).xyz;     

    // Dither
    col += ditherTable[int( coor.x ) % 4][int( coor.y ) % 4] * 0.005; // last number is dithering strength

    // Reduce colors    
    col = floor(col * COLOR_FACTOR) / COLOR_FACTOR;    
   
    // Output to screen
    gl_FragColor = vec4(col,1.);
}
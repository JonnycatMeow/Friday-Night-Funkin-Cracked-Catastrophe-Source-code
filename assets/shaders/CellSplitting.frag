uniform vec2 iResolution;
uniform float iTime;

const float CELL_COUNT = 5.0;
const float CHILD_CELL_COUNT = CELL_COUNT*2.0;
const float PI = 3.1415926535;
const float TWO_PI = PI*2.0;
float CHILD_CELL_BORDER_THICKNESS = 0.003;

float random(float seed)
{
    return fract(mod(sin(dot(seed, 12.9898)), TWO_PI)*43758.5453);
}
float random(vec2 seed)
{
    return fract(mod(sin(dot(seed, vec2(12.9898, 78.233))), TWO_PI)*43758.5453);
}
vec2 random2(vec2 seed)
{
    float r = random(seed);
    return vec2(r, random(r));
}

void main()
{
    vec2 fragCoord = openfl_TextureCoordv * iResolution;

    vec2 uv = fragCoord.xy/iResolution.xy;
   
    vec2 scaled_uv = uv*CELL_COUNT;
    
    vec2 cell_index = floor(scaled_uv);
    vec2 cell_uv    = fract(scaled_uv);
    vec2 cell_id = random2(cell_index);
    
    vec2 boundary = (sin(cell_id*TWO_PI+iTime)*0.5+0.5)*0.5+0.25;
    vec2 is_out_of_boundary = step(boundary, cell_uv);
    
    vec2 childcell_index = cell_index*2.0+is_out_of_boundary;
    vec2 childcell_uv = mix(cell_uv/boundary, (cell_uv-boundary)/(1.0-boundary), is_out_of_boundary);
    vec2 childcell_size = mix(boundary, 1.0-boundary, is_out_of_boundary)/CHILD_CELL_COUNT;
    vec2 childcell_border = CHILD_CELL_BORDER_THICKNESS/childcell_size;
    childcell_border.x *= iResolution.y/iResolution.x;
    
    vec2 texture_uv = (childcell_index+childcell_uv)/CHILD_CELL_COUNT;  
    
    vec3 color = vec3(texture2D(bitmap, texture_uv));
    color *= step(childcell_border.x, childcell_uv.x)*step(childcell_border.y, childcell_uv.y);
    
    // Visualizing childcell_uv
    color *= mix(1.0, childcell_uv.x*childcell_uv.y, step(5.0, mod(iTime, 10.0)));
    
    gl_FragColor = vec4(color, 1.0);
}
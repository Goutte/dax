part of dax;


/**
 * vPos requires shared VERTEX_POSITION
 */
class WoodLayer extends MaterialLayer {

  String get glslVertex => """
shared attribute vec3 VERTEX_POSITION;

varying vec3 vPos;

void main(void) {
  vPos = VERTEX_POSITION.xyz;
}
  """;

  String get glslFragment => """
uniform vec3  LightWood;
uniform vec3  DarkWood;
uniform float RingFreq;
uniform float LightGrains;
uniform float DarkGrains;
uniform float GrainThresh;
uniform vec3  NoiseScale;
uniform float Noisiness;
uniform float GrainScale;

varying vec3 vPos;




/*
 * "gradTexture" is a 256x256 RGBA texture that is used for both the
 * permutations, encoded in A, and the 2D, 3D and 4D gradients,
 * encoded in RGB with x in R, y in B and z and w combined in B.
 * For details, see the main C program.
 */
shared uniform sampler2D gradTexture;

/*
 * To create offsets of one texel and one half texel in the
 * texture lookup, we need to know the texture image size.
 */
#define ONE 0.00390625
#define ONEHALF 0.001953125
// The numbers above are 1/256 and 0.5/256, change accordingly
// if you change the code to use another texture size.



/*
 * Efficient simplex indexing functions by Bill Licea-Kane, ATI. Thanks!
 * (This was originally implemented as a 1D texture lookup. Nice to avoid that.)
 */
void simplex( const in vec3 P, out vec3 offset1, out vec3 offset2 )
{
  vec3 offset0;

  vec2 isX = step( P.yz, P.xx ); // P.x >= P.y ? 1.0 : 0.0;  P.x >= P.z ? 1.0 : 0.0;
  offset0.x  = isX.x + isX.y;    // Accumulate all P.x >= other channels in offset.x
  offset0.yz = 1.0 - isX;        // Accumulate all P.x <  other channels in offset.yz

  float isY = step( P.z, P.y );  // P.y >= P.z ? 1.0 : 0.0;
  offset0.y += isY;              // Accumulate P.y >= P.z in offset.y
  offset0.z += 1.0 - isY;        // Accumulate P.y <  P.z in offset.z

  // offset0 now contains the unique values 0,1,2 in each channel
  // 2 for the channel greater than other channels
  // 1 for the channel that is less than one but greater than another
  // 0 for the channel less than other channels
  // Equality ties are broken in favor of first x, then y
  // (z always loses ties)

  offset2 = clamp( offset0, 0.0, 1.0 );
  // offset2 contains 1 in each channel that was 1 or 2
  offset1 = clamp( offset0-1.0, 0.0, 1.0 );
  // offset1 contains 1 in the single channel that was 1
}

void simplex( const in vec4 P, out vec4 offset1, out vec4 offset2, out vec4 offset3 )
{
  vec4 offset0;

  vec3 isX = step( P.yzw, P.xxx );        // See comments in 3D simplex function
  offset0.x = isX.x + isX.y + isX.z;
  offset0.yzw = 1.0 - isX;

  vec2 isY = step( P.zw, P.yy );
  offset0.y += isY.x + isY.y;
  offset0.zw += 1.0 - isY;

  float isZ = step( P.w, P.z );
  offset0.z += isZ;
  offset0.w += 1.0 - isZ;

  // offset0 now contains the unique values 0,1,2,3 in each channel

  offset3 = clamp( offset0, 0.0, 1.0 );
  offset2 = clamp( offset0-1.0, 0.0, 1.0 );
  offset1 = clamp( offset0-2.0, 0.0, 1.0 );
}

/*
 * 3D simplex noise. Comparable in speed to classic noise, better looking.
 */
float snoise(vec3 P) {

// The skewing and unskewing factors are much simpler for the 3D case
#define F3 0.333333333333
#define G3 0.166666666667

  // Skew the (x,y,z) space to determine which cell of 6 simplices we're in
  float s = (P.x + P.y + P.z) * F3; // Factor for 3D skewing
  vec3 Pi = floor(P + s);
  float t = (Pi.x + Pi.y + Pi.z) * G3;
  vec3 P0 = Pi - t; // Unskew the cell origin back to (x,y,z) space
  Pi = Pi * ONE + ONEHALF; // Integer part, scaled and offset for texture lookup

  vec3 Pf0 = P - P0;  // The x,y distances from the cell origin

  // For the 3D case, the simplex shape is a slightly irregular tetrahedron.
  // To find out which of the six possible tetrahedra we're in, we need to
  // determine the magnitude ordering of x, y and z components of Pf0.
  vec3 o1;
  vec3 o2;
  simplex(Pf0, o1, o2);

  // Noise contribution from simplex origin
  float perm0 = texture2D(gradTexture, Pi.xy).a;
  vec3  grad0 = texture2D(gradTexture, vec2(perm0, Pi.z)).rgb * 4.0 - 2.0;
  grad0.z = floor(grad0.z); // Remove small variations due to w
  float t0 = 0.6 - dot(Pf0, Pf0);
  float n0;
  if (t0 < 0.0) n0 = 0.0;
  else {
    t0 *= t0;
    n0 = t0 * t0 * dot(grad0, Pf0);
  }

  // Noise contribution from second corner
  vec3 Pf1 = Pf0 - o1 + G3;
  float perm1 = texture2D(gradTexture, Pi.xy + o1.xy*ONE).a;
  vec3  grad1 = texture2D(gradTexture, vec2(perm1, Pi.z + o1.z*ONE)).rgb * 4.0 - 2.0;
  grad1.z = floor(grad1.z); // Remove small variations due to w
  float t1 = 0.6 - dot(Pf1, Pf1);
  float n1;
  if (t1 < 0.0) n1 = 0.0;
  else {
    t1 *= t1;
    n1 = t1 * t1 * dot(grad1, Pf1);
  }

  // Noise contribution from third corner
  vec3 Pf2 = Pf0 - o2 + 2.0 * G3;
  float perm2 = texture2D(gradTexture, Pi.xy + o2.xy*ONE).a;
  vec3  grad2 = texture2D(gradTexture, vec2(perm2, Pi.z + o2.z*ONE)).rgb * 4.0 - 2.0;
  grad2.z = floor(grad2.z); // Remove small variations due to w
  float t2 = 0.6 - dot(Pf2, Pf2);
  float n2;
  if (t2 < 0.0) n2 = 0.0;
  else {
    t2 *= t2;
    n2 = t2 * t2 * dot(grad2, Pf2);
  }

  // Noise contribution from last corner
  vec3 Pf3 = Pf0 - vec3(1.0-3.0*G3);
  float perm3 = texture2D(gradTexture, Pi.xy + vec2(ONE, ONE)).a;
  vec3  grad3 = texture2D(gradTexture, vec2(perm3, Pi.z + ONE)).rgb * 4.0 - 2.0;
  grad3.z = floor(grad3.z); // Remove small variations due to w
  float t3 = 0.6 - dot(Pf3, Pf3);
  float n3;
  if(t3 < 0.0) n3 = 0.0;
  else {
    t3 *= t3;
    n3 = t3 * t3 * dot(grad3, Pf3);
  }

  // Sum up and scale the result to cover the range [-1,1]
  return 20.0 * (n0 + n1 + n2 + n3);
}


void main(void) {

  float n = snoise(vPos * NoiseScale) * Noisiness;

  vec3 noisevec = vec3(snoise(vPos*1.0 * NoiseScale) / 1.0 * Noisiness,
                       snoise(vPos*2.0 * NoiseScale) / 2.0 * Noisiness,
                       snoise(vPos*4.0 * NoiseScale) / 4.0 * Noisiness);

  vec3 location = vPos + noisevec;
  float dist = sqrt(location.x * location.x + location.y * location.y + location.z * location.z);
  dist *= RingFreq;

  float r = fract(dist + noisevec.x + noisevec.y + noisevec.z) * 2.0;
  if (r > 1.0) r = 2.0 - r;

  vec3 color = mix(LightWood, DarkWood, r);
  r = fract((vPos.x + vPos.z) * GrainScale + 0.5);
  noisevec.z *= r;
  if (r < GrainThresh)
    color += LightWood * LightGrains * noisevec.z;
  else
    color -= LightWood * DarkGrains * noisevec.z;


  gl_FragColor = vec4(color, 1.0);

}
  """;

  Map<String, dynamic> onSetup(World world, Model model, Renderer renderer) {
    return {
      'LightWood':  new Vector3(0.40, 0.3, 0.1),
      'DarkWood':   new Vector3(0.3, 0.2, 0.07),
      'RingFreq':    0.25,
      'LightGrains': 1.0,
      'DarkGrains':  0.0,
      'GrainThresh': 0.42,
      'NoiseScale': new Vector3(0.51, 0.15, 0.1),
      'Noisiness':   2.00,
      'GrainScale':  0.0,
    };
  }

  double _red_t = 0.0;

  Map<String, dynamic> onDraw(World world, Model model, Renderer renderer) {
    _red_t += 0.02;
    double _red = (sin(_red_t) + 1) / 2;
    return {
//      'RingFreq': 0.10 + (sin(_red_t/2) + 1) / 2,
//      'LightGrains': (sin(_red_t/5) + 1) / 2,
//      'DarkGrains': (sin(_red_t/3) + 1) / 2,
//      'Noisiness': 1.80 + sin(_red_t/3)/4,
//      'uColor': new Vector3(_red, 1.0-_red, 0.5),
    };
  }

}
uniform sampler2D adsk_results_pass7;
uniform float adsk_result_w, adsk_result_h;
float chromatic_abb = 0.05;
float d_amount = 12.0;

vec2 center = vec2(0.5);
int num_iter = 24;

vec2 res = vec2(adsk_result_w, adsk_result_h);

vec2 barrelDistortion(vec2 coord, float amt) 
{
	
	vec2 cc = (gl_FragCoord.xy/res.xy) - center;
	float distortion = dot(cc * d_amount * .3, cc);

	return coord + cc * distortion * -1. * amt;
}

float sat( float t )
{
	return clamp( t, 0.0, 1.0 );
}

float linterp( float t ) {
	return sat( 1.0 - abs( 2.0*t - 1.0 ) );
}

float remap( float t, float a, float b ) {
	return sat( (t - a) / (b - a) );
}

vec3 spectrum_offset( float t ) {
	vec3 ret;
	float lo = step(t,0.5);
	float hi = 1.0-lo;
	float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
	ret = vec3(lo,1.0,hi) * vec3(1.0-w, w, 1.0-w);

	return pow( ret, vec3(1.0/2.2) );
}

void main()
{	
	vec2 uv= gl_FragCoord.xy/res.xy;
	vec3 sumcol = vec3(0.0);
	vec3 sumw = vec3(0.0);
		
	for ( int i=0; i<num_iter;++i )
	{
		float t = float(i) * (1.0 / float(num_iter));
		vec3 w = spectrum_offset( t );
		sumw += w;
		sumcol += w * texture2D( adsk_results_pass7, barrelDistortion(uv, chromatic_abb * t ) ).rgb;
	}
	
	gl_FragColor = vec4(sumcol.rgb / sumw,  1.0 );
}

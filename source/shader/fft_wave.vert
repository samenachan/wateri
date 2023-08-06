#version 300 es
precision highp float;

in vec3 in_VertexPosition;
in vec4 in_VertexColor;
in int in_vertexIndex;
in vec2 in_H0;
in vec2 in_H0m;
uniform mat4 u_ModelMatrix;
uniform mat4 u_ViewMatrix;
uniform mat4 u_ProjectionMatrix;
uniform float u_Time;
uniform int u_N;
out vec4 out_Color;
out vec2 out_Ht;

const float PI  = 3.1415926;
const float INVPI = 1.0 / PI;

vec2 conjugate(vec2 arg)
{
	vec2 f2;
	f2.x = arg.x;
	f2.y = -arg.y;
	return f2;
}

vec2 complex_exp(float arg)
{
	return vec2(cos(arg), sin(arg));
}

vec2 complex_add(vec2 a, vec2 b)
{
	return vec2(a.x + b.x, a.y + b.y);
}

vec2 complex_mult(vec2 ab, vec2 cd)
{
	return vec2(ab.x * cd.x - ab.y * cd.y, ab.x * cd.y + ab.y * cd.x);
}

vec2 GenerateSpectrumKernel(int x_index, int y_index)
{
	int Lx = u_N * 5 / 2;
	int Ly = u_N * 5 / 2;
	vec2 k;
	k.x = float(- u_N / 2 + x_index) * (2.0 * PI / float(Lx));
	k.y = float(- u_N / 2 + y_index) * (2.0 * PI / float(Ly));
	float k_len = sqrt(k.x * k.x + k.y * k.y);
	float omega = sqrt(9.81f * k_len);
	vec2 h0_k = in_H0;
	vec2 h0_mk = in_H0m;
	return complex_add(complex_mult(h0_k, complex_exp(omega * u_Time)), complex_mult(conjugate(h0_mk), complex_exp(-omega * u_Time)));
}

void main() {
	mat4 mvpMatrix = u_ProjectionMatrix * u_ViewMatrix * u_ModelMatrix;
	gl_Position = mvpMatrix * vec4(in_VertexPosition, 1.0);

	out_Color = in_VertexColor;

	int index = in_vertexIndex;
	int y_index = int(index / u_N);
	int x_index = index % u_N;
	out_Ht = GenerateSpectrumKernel(x_index, y_index);
}
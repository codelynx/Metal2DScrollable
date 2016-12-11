//
//	Shaders.metal
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 12/10/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct VertexInOut
{
	float4  position [[position]];
	float4  color;
};

struct Uniforms {
	float4x4 modelViewProjectionMatrix;
};

vertex VertexInOut vertex_shader(uint vid [[ vertex_id ]],
									 constant packed_float4* position [[ buffer(0) ]],
									 constant packed_float4* color [[ buffer(1) ]],
									 constant Uniforms & uniforms [[ buffer(2) ]]
){
	VertexInOut outVertex;
	
	outVertex.position = uniforms.modelViewProjectionMatrix * float4(position[vid]);
	outVertex.color = color[vid];
	
	return outVertex;
};

fragment half4 fragment_shader(VertexInOut inFrag [[stage_in]])
{
	return half4(inFrag.color);
};

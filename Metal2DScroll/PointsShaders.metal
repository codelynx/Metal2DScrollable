//
//	PointsShaders.metal
//	Metal2DScroll
//
//	Created by Kaz Yoshikawa on 1/11/16.
//	Copyright © 2016 Electricwoods LLC. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;


struct VertexIn {
	packed_float2 position;
};

struct VertexOut {
	float4 position [[ position ]];
	float pointSize [[ point_size ]];
};

struct Uniforms {
	float4x4 transform;
};

vertex VertexOut points_vertex(
	device VertexIn * vertices [[ buffer(0) ]],
	constant Uniforms & uniforms [[ buffer(1) ]],
	uint vid [[ vertex_id ]]
) {
	VertexIn inVertex = vertices[vid];
	VertexOut outVertex;
	
	outVertex.position = uniforms.transform * float4(inVertex.position, 0.0, 1.0);
	outVertex.pointSize = 32;
	return outVertex;
}

fragment float4 points_fragment(
	VertexOut vertexIn [[ stage_in ]],
	texture2d<float, access::sample> colorTexture [[ texture(0) ]],
	sampler colorSampler [[ sampler(0) ]],
	float2 texcoord [[ point_coord ]]
) {
	float4 color = colorTexture.sample(colorSampler, texcoord);
	if (color.a == 0.0) {
		discard_fragment();
	}
	return color;
}

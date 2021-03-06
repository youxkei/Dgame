module Dgame.System.VertexRenderer;

private {
	debug import std.stdio;
	
	import derelict.opengl3.gl;
}

/**
 * Primitive Types and targets
 */
final abstract class Primitive {
	/**
	 * Primitive Types for the draw methods
	 */
	enum Type {
		Quad		= GL_QUADS,				/** Declare that the stored vertices are Quads. */
		QuadStrip	= GL_QUAD_STRIP,		/** Declare that the stored vertices are Quad Strips*/
		Triangle	= GL_TRIANGLES,			/** Declare that the stored vertices are Triangles. */
		TriangleStrip = GL_TRIANGLE_STRIP,	/** Declare that the stored vertices are Triangles Strips */
		TriangleFan = GL_TRIANGLE_FAN,		/** Declare that the stored vertices are Triangles Fans. */
		Lines		= GL_LINES,				/** Declare that the stored vertices are Lines. */
		LineStrip	= GL_LINE_STRIP,		/** Declare that the stored vertices are Line Strips. */
		LineLoop	= GL_LINE_LOOP,			/** Declare that the stored vertices are Line Loops. */
		Polygon		= GL_POLYGON			/** Declare that the stored vertices are Polygons. */
	}
	
	/**
	 * Declare which data is stored. Possible are Vertices, Colors or Texture coordinates.
	 */
	enum Target {
		None   = 0,		/** Declare that the data consist of nothing relevant. */
		Vertex = 1, 	/** Declare that the data consist of vertices. */
		Color  = 2, 	/** Declare that the data consist of colors. */
		TexCoords = 4 	/** Declare that the data consist of texture coordinates. */
	}
}

/**
 * Buffer is a wrapper for a static Vertex Array.
 * <b>It has nothing to do with the class VertexArray</b>
 *
 * Author: rschuett
 */
final abstract class VertexRenderer {
public:
	/**
	 * Points to a specific Primitive.Target.
	 * 
	 * See: glVertexPointer
	 * See: glColorPointer
	 * See: glTexCoordPointer
	 * See: Primitive.Target enum.
	 */
	static void pointTo(Primitive.Target trg, void* ptr = null,
	                    ubyte stride = 0, ubyte offset = 0)
	{
		VertexRenderer.enableState(trg);
		
		if (ptr)
			ptr += offset;
		else if (offset != 0)
			ptr = cast(void*)(offset);
		
		final switch (trg) {
			case Primitive.Target.None:
				assert(0, "Invalid Primitive.Target");
			case Primitive.Target.Vertex:
				glVertexPointer(3, GL_FLOAT, stride, ptr);
				break;
			case Primitive.Target.Color:
				glColorPointer(4, GL_FLOAT, stride, ptr);
				break;
			case Primitive.Target.TexCoords:
				glTexCoordPointer(2, GL_FLOAT, stride, ptr);
				break;
		}
	}
	
	/**
	 * Enable a specific client state (with glEnableClientState)
	 * like GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	 * with the corresponding Primitive.Target.
	 */
	static void enableState(Primitive.Target trg) {
		if (trg & Primitive.Target.None)
			assert(0, "Invalid Primitive.Target");
		
		if (trg & Primitive.Target.Vertex)
			glEnableClientState(GL_VERTEX_ARRAY);
		
		if (trg & Primitive.Target.Color)
			glEnableClientState(GL_COLOR_ARRAY);
		
		if (trg & Primitive.Target.TexCoords)
			glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Enable all client states
	 */
	static void enableAllStates() {
		VertexRenderer.enableState(Primitive.Target.Vertex
		                           | Primitive.Target.Color
		                           | Primitive.Target.TexCoords);
	}
	
	/**
	 * Disable all client states
	 */
	static void disableAllStates() {
		VertexRenderer.disableState(Primitive.Target.Vertex
		                            | Primitive.Target.Color
		                            | Primitive.Target.TexCoords);
	}
	
	/**
	 * Disable a specific client state (with glDisableClientState)
	 */
	static void disableState(Primitive.Target trg) {
		if (trg & Primitive.Target.None)
			assert(0, "Invalid Primitive.Target");
		
		if (trg & Primitive.Target.Vertex)
			glDisableClientState(GL_VERTEX_ARRAY);
		
		if (trg & Primitive.Target.Color)
			glDisableClientState(GL_COLOR_ARRAY);
		
		if (trg & Primitive.Target.TexCoords)
			glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices.
	 *
	 * See: pointTo
	 */
	static void drawArrays(Primitive.Type ptype, size_t count, uint start = 0) {
		glDrawArrays(ptype, start, cast(int) count);
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices and indices for the correct index per vertex.
	 * 
	 * See: pointTo
	 */
	static void drawElements(Primitive.Type ptype, size_t count, uint[] indices) {
		if (indices.length == 0)
			return;
		
		glDrawElements(ptype, cast(int) count, GL_UNSIGNED_INT, &indices[0]); 
	}
	
	/**
	 * Draw Shapes of a specific type from the data which is addressed through 'pointTo'.
	 * It will use count vertices and indices for the correct index per vertex.
	 * 
	 * Note: If start or end are -1 or below, 0 and indices.length are used.
	 * 
	 * See: pointTo
	 */
	static void drawRangeElements(Primitive.Type ptype, size_t count,
	                              uint[] indices, uint start = 0, uint end = 0)
	{
		if (indices.length == 0)
			return;
		
		glDrawRangeElements(
			ptype,
			start,
			end != 0 ? end : cast(int) indices.length,
			cast(int) count,
			GL_UNSIGNED_INT,
			&indices[0]);
	}
}
module Dgame.Graphics.RendererTexture;

private {
	debug import std.stdio;
	
	import derelict.sdl2.sdl;
	
	import Dgame.Core.Memory.SmartPointer.Shared;
	import Dgame.Graphics.Surface;
	import Dgame.Graphics.Color;
	import Dgame.Graphics.Renderer;
	import Dgame.Math.Rect;
}

///version = Develop;

/**
 * This is a wrapper for the hardware acceleration of SDL_Surfaces, called SDL_Textures.
 * That means it is the same as if you use the HW_ACCEL Flag in SDL 1.2.
 *
 * Author: rschuett
 */
struct RendererTexture {
public:
	/**
	 * Supported Access modes
	 */
	enum Access {
		Static = SDL_TEXTUREACCESS_STATIC,		/** changes rarely, not lockable */
		Stream = SDL_TEXTUREACCESS_STREAMING	/** changes frequently, lockable */
	}
	
	const Access access;
	
private:
	shared_ptr!(SDL_Texture, SDL_DestroyTexture) _target;
	
public:
	/**
	 * CTor
	 */
	this(SDL_Texture* tex, Access access) {
		this._target.reset(tex);
		
		this.access = access;
	}
	
	version (Develop)
	~this() {
		debug writeln("DTor RendererTexture");
	}
	
	/**
	 * Destroy the RendererTexture
	 */
	void free() {
		this._target.release();
	}
	
	/**
	 * Returns a two dimensional array filled with the width and the height
	 */
	int[2] getSize() {
		int w, h;
		int access;
		uint format;
		
		SDL_QueryTexture(this._target, &format, &access, &w, &h);
		
		return [w, h];
	}
	
	/**
	 * Returns the width
	 */
	@property
	ushort width() {
		int[2] size = this.getSize();
		
		return cast(ushort) size[0];
	}
	
	/**
	 * Returns the width
	 */
	@property
	ushort height() {
		int[2] size = this.getSize();
		
		return cast(ushort) size[1];
	}
	
	/**
	 * Checks whether this Surface is lockable and therefore accessable.
	 */
	bool isLockable() const pure nothrow {
		return !(this.access & Access.Static);
	}
	
	/**
	 * Use this function to lock a portion of the texture for write-only pixel access.
	 * Returns the pixel data of given area.
	 * If area is null, the whole pixel data returns.
	 */
	void* lock(out int pitch, const ShortRect* area = null) {
		if (this.access & Access.Static)
			return null;
		
		const SDL_Rect* rect_ptr = area ? area.ptr : null;
		
		void* pixels;
		SDL_LockTexture(this._target, rect_ptr, &pixels, &pitch);
		
		return pixels;
	}
	
	/**
	 * Use this function to unlock a texture, uploading the changes to video memory, if needed.
	 */
	void unlock() {
		SDL_UnlockTexture(this._target);
	}
	
	/**
	 * Returns a pointer of the SDL_Texture* struct.
	 */
	@property
	inout(SDL_Texture)* ptr() inout {
		return this._target.ptr;
	}
	
	/**
	 * Checks whether the RendererTexture is valid.
	 */
	bool isValid() const pure nothrow {
		return this._target.isValid();
	}
	
	/**
	 * Use this function to update the given texture rectangle with new pixel data.
	 */
	void update(const void* pixels, const ShortRect* rect, int pitch = -1) {
		const SDL_Rect* dst_ptr = rect ? rect.ptr : null;
		
		SDL_UpdateTexture(this._target, dst_ptr, pixels, !pitch ? this.width * 4 : pitch);
	}
	
	/**
	 * Copy hw onto this RendererTexture. rect is the position and size.
	 */
	void copy(ref RendererTexture hw, const ShortRect* rect) in {
		assert(hw.isValid(), "Invalid Surface.");
	} body {
		int pitch;
		void* pixels = hw.lock(pitch);
		scope(exit) hw.unlock();
		
		this.update(pixels, rect, pitch);
	}
	
	/**
	 * Copy srfc onto this RendererTexture. rect is the position and size.
	 */
	void copy(ref Surface srfc, ShortRect* rect) in {
		assert(srfc.isValid(), "Invalid Surface.");
	} body {
		ShortRect clipRect = srfc.getClipRect();
		if (rect is null)
			rect = &clipRect;
		
		this.update(srfc.getPixels(), rect, srfc.ptr.pitch);
	}
	
	/**
	 * Use this function to set the blend mode for a texture, used by 'copy'.
	 */
	void setBlendMode(Renderer.BlendMode bmode) {
		SDL_SetTextureBlendMode(this._target, bmode);
	}
	
	/**
	 * Use this function to get the blend mode used for texture copy operations.
	 */
	Renderer.BlendMode getBlendMode() {
		SDL_BlendMode blendMode;
		SDL_GetTextureBlendMode(this._target, &blendMode);
		
		return cast(Renderer.BlendMode) blendMode;
	}
	
	/**
	 * Use this function to set an additional alpha value multiplied into render copy operations.
	 */
	void setAlphaMod(ubyte alpha) {
		SDL_SetTextureAlphaMod(this._target, alpha);
	}
	
	/**
	 * Use this function to get the additional alpha value multiplied into render copy operations.
	 */
	ubyte getAlphaMod() {
		ubyte alpha;
		SDL_GetTextureAlphaMod(this._target, &alpha);
		
		return alpha;
	}
	
	/**
	 * Use this function to set an additional color value multiplied into render copy operations.
	 */
	void setColorMod(ref const Color col) {
		this.setColorMod(col.red, col.green, col.blue);
	}
	
	/**
	 * Rvalue version
	 */
	void setColorMod(const Color col) {
		this.setColorMod(col);
	}
	
	/**
	 * Use this function to set an additional color value multiplied into render copy operations.
	 */
	void setColorMod(ubyte r, ubyte g, ubyte b) {
		SDL_SetTextureColorMod(this._target, r, g, b);
	}
	
	/**
	 * Use this function to get the additional color value multiplied into render copy operations
	 */
	Color getColorMod() {
		ubyte r, g, b;
		SDL_GetTextureColorMod(this._target, &r, &g, &b);
		
		return Color(r, g, b);
	}
}

module Dgame.Graphics.Font;

private {
	debug import std.stdio;
	import std.file : exists;
	import std.conv : to;
	import std.string : format;
	import std.c.string : memcpy;
	
	import derelict3.sdl2.ttf;
}

private Font*[] _finalizer;

void _finalizeFont() {
	debug writefln("Finalize Font (%d)", _finalizer.length);
	
	for (size_t i = 0; i < _finalizer.length; i++) {
		debug writefln(" -> Font finalized: %d", i);
		
		if (_finalizer[i])
			_finalizer[i].free();
	}
	
	_finalizer = null;
	
	debug writeln(" >> Font Finalized");
}

/**
 * Font is the low-level class for loading and manipulating character fonts.
 * This class is meant to be used by Dgame.Graphics.Text.
 *
 * Author: rschuett
 */
struct Font {
public:
	/**
	 * Font styles
	 */
	enum Style {
		Bold      = TTF_STYLE_BOLD,			/** Makes the text bold */
		Italic    = TTF_STYLE_ITALIC,		/** Makes the text italic */
		Underline = TTF_STYLE_UNDERLINE,	/** Underline the text */
		Crossed   = TTF_STYLE_STRIKETHROUGH, /** Cross the text */
		Normal    = TTF_STYLE_NORMAL		/** Normal text without any style. */
	}
	
	/**
	 * Font mode
	 */
	enum Mode {
		Solid,  /** Solid mode is dirty but fast. */
		Shaded, /** Blended is optimized but still fast. */
		Blended /** Nicest but slowest mode. */
	}
	
private:
	TTF_Font* _font;
	
	string _fontFile;
	ubyte _fontSize;
	
	Mode _mode;
	Style _style;
	
public:
	/**
	 * CTor
	 */
	this(string filename, ubyte size, Mode mode = Mode.Solid, Style style = Style.Normal) {
		this._mode  = mode;
		this._style = style;
		
		this.loadFromFile(filename, size);
	}
	
	/**
	 * Postblit
	 */
	this(this) {
		debug writeln("Font Postblit");
		
		_finalizer ~= &this;
	}
	
	/**
	 * opAssign
	 */
	void opAssign(ref const Font fnt) {
		debug writeln("Font opAssign");
		
		this._mode = fnt._mode;
		this._style = fnt._style;
		
		this.loadFromFile(fnt._fontFile, fnt._fontSize); /// freed
	}
	
	/**
	 * DTor
	 */
	~this() {
		this.free();
	}
	
	/**
	 * Close and release the current font.
	 * This function is claaed from the DTor
	 */
	void free() {
		if (this._font) {
			//	try {
			debug writeln("close Font: ", this._font, ',', TTF_WasInit());
			TTF_CloseFont(this._font);
			debug writeln("Font closed");
			//} catch (Throwable e) { }
			
			this._font = null;
		}
	}
	
	/**
	 * Load the font from a file.
	 * If the second parameter isn't 0, the current font size will be replaced with that.
	 * If both are 0, an exception is thrown.
	 */
	void loadFromFile(string fontFile, ubyte fontSize = 0) {
		this.free(); /// Free old data
		
		_finalizer ~= &this;
		
		assert(this._fontSize != 0 || fontSize != 0, "No size for this font.");
		
		if (!exists(fontFile)) {
			throw new Exception("Font File does not exists.");
		}
		
		try {
			this._font = TTF_OpenFont(fontFile.ptr, fontSize == 0 ? this._fontSize : fontSize);
			debug writefln("#1 -> Error: %s", to!(string)(TTF_GetError()));
		} catch (Throwable t) {
			debug writefln(" -> Font Size: %d", fontSize == 0 ? this._fontSize : fontSize);
			throw new Exception(.format("Error by opening font file %s: %s.", fontFile, t.msg));
		}
		
		if (this._font is null) {
			debug writefln("#2 -> Error: %s", to!(string)(TTF_GetError()));
			throw new Exception("Die Font konnte nicht geladen werden.");
		}
		
		this._fontFile = fontFile;
		this._fontSize = fontSize;
	}
	
	/**
	 * Returns the current filename of the font.
	 */
	string getFontFile() const pure nothrow {
		return this._fontFile;
	}
	
	/**
	 * Set the font style.
	 *
	 * See: Font.Style enum
	 */
	void setStyle(Style style) {
		TTF_SetFontStyle(this._font, style);
	}
	
	/**
	 * Returns the current font style.
	 *
	 * See: Font.Style enum
	 */
	Style getStyle() const {
		return cast(Style) TTF_GetFontStyle(this._font);
	}
	
	/**
	 * Set the font mode.
	 *
	 * See: Font.Mode enum
	 */
	void setMode(Mode mode) {
		this._mode = mode;
	}
	
	/**
	 * Returns the current font mode.
	 *
	 * See: Font.Mode enum
	 */
	Mode getMode() const pure nothrow {
		return this._mode;
	}
	
	/**
	 * Replace or set the font size.
	 */
	void setSize(ubyte size) {
		this._fontSize = size;
	}
	
	/**
	 * Returns the current font size.
	 */
	ubyte getSize() const pure nothrow {
		return this._fontSize;
	}
	
	/**
	 * Returns a TTF_Font pointer.
	 */
	@property
	inout(TTF_Font)* ptr() inout {
		return this._font;
	}
}